import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/model/cache_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

///渲染节点
abstract class RenderNode extends Disposable with ViewAttr {
  final String id = randomId();

  RenderNode? _parent;

  RenderNode? get parent => _parent;

  @protected
  set parent(RenderNode? p) => _parent = p;

  late Paint mPaint = Paint();

  ///索引层次(影响其绘制顺序)
  int zLevel = 0;

  RenderNodeStatus nodeStatus = RenderNodeStatus.none;

  bool _dirty = true;
  bool _forceLayout = true;

  bool get forceLayout => _forceLayout;

  @protected
  set forceLayout(bool f) => _forceLayout = f;

  ///绘图缓存(可以优化绘制效率)
  late final CacheLayer cacheLayer = CacheLayer();

  void measure(double parentWidth, double parentHeight) {
    if (nodeStatus.inMeasure || nodeStatus.inLayout) {
      return;
    }
    nodeStatus = RenderNodeStatus.measureStart;
    const accurate = StaticConfig.accuracy;
    bool minDiff = (width - parentWidth).abs() <= accurate && (height - parentHeight).abs() <= accurate;
    if (forceLayout || !minDiff) {
      ///大小发生改变 需要重新布局
      forceLayout = true;
      oldBound = boxBound;
      margin.reset();
      padding.reset();
      Size size = onMeasure(parentWidth, parentHeight);
      boxBound = Rect.fromLTWH(0, 0, size.width, size.height);
    }
    nodeStatus = RenderNodeStatus.measureEnd;
  }

  Size onMeasure(double parentWidth, double parentHeight) {
    LayoutParams lp = layoutParams;
    double w = lp.width.convert(parentWidth);
    double h = lp.height.convert(parentHeight);
    if (lp.width.isWrap) {
      padding.left = lp.getLeftPadding(parentWidth);
      padding.right = lp.getRightPadding(parentWidth);
      w += padding.horizontal;
    }
    if (lp.height.isWrap) {
      padding.top = lp.getTopPadding(parentHeight);
      padding.bottom = lp.getBottomPadding(parentHeight);
      h += padding.vertical;
    }
    w = min<double>([w, parentWidth]);
    h = min<double>([h, parentHeight]);

    return Size(w, h);
  }

  ///记录布局次数
  int _layoutCount = 0;

  void layout(double left, double top, double right, double bottom) {
    if (nodeStatus.inLayout || nodeStatus.inMeasure) {
      Logger.i("$runtimeType layout inLayout:${nodeStatus.inLayout}  inMeasure:${nodeStatus.inMeasure}");
      return;
    }
    nodeStatus = RenderNodeStatus.layoutStart;
    const accurate = StaticConfig.accuracy;
    bool b1 = (left - boxBound.left).abs() < accurate;
    bool b2 = (top - boxBound.top).abs() < accurate;
    bool b3 = (right - boxBound.right).abs() < accurate;
    bool b4 = (bottom - boxBound.bottom).abs() < accurate;
    if ((b1 && b2 && b3 && b4) && !forceLayout) {
      nodeStatus = RenderNodeStatus.layoutEnd;
      return;
    }
    forceLayout = false;
    _layoutCount++;
    oldBound = boxBound;
    boxBound = Rect.fromLTRB(left, top, right, bottom);
    globalBound = getGlobalBounds();
    onLayout(left, top, right, bottom);
    onLayoutEnd();
    nodeStatus = RenderNodeStatus.layoutEnd;
  }

  bool get isFirstLayout => _layoutCount == 1;

  void onLayout(double left, double top, double right, double bottom) {}

  void onLayoutEnd() {}

  void clearCacheLayer() {
    cacheLayer.clear();
  }

  void draw(CCanvas canvas) {
    clearDirty();
    if (notShow || nodeStatus.inDrawing || nodeStatus != RenderNodeStatus.layoutEnd) {
      return;
    }
    nodeStatus = RenderNodeStatus.drawing;
    onDrawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    onDrawForeground(canvas);
    nodeStatus = RenderNodeStatus.layoutEnd;
  }

  bool drawSelf(CCanvas canvas, ChartViewGroup parent) {
    final bool dirty = isDirty;
    clearDirty();
    if (notShow) {
      return false;
    }

    var layer = cacheLayer.layer;
    final notChange = cacheLayer.notChange(width, height, translationX, translationY, scaleX, scaleY);
    if (useSingleLayer && layer != null && !dirty && notChange) {
      canvas.paintContext.addLayer(layer);
      return true;
    }

    if (!useSingleLayer) {
      _drawInner(canvas, Offset(left, top), true);
      return false;
    }

    var oldLayer = layer;

    var newLayer = canvas.paintContext.pushClipRect(
      true,
      globalBound.topLeft,
      Rect.fromLTWH(0, 0, width, height),
      (context, offset) {
        _drawInner(CCanvas(context), offset, true);
      },
      oldLayer: oldLayer as ClipRectLayer?,
    );
    cacheLayer.saveByView(newLayer, this);

    return false;
  }

  void _drawInner(CCanvas canvas, Offset offset, bool clip) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (clip) {
      canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    }
    draw(canvas);
    canvas.restore();
  }

  void onDrawBackground(CCanvas canvas) {}

  void onDraw(CCanvas canvas) {}

  void onDrawEnd(CCanvas canvas) {}

  ///用于ViewGroup覆写
  void dispatchDraw(CCanvas canvas) {}

  ///实现绘制前景色
  void onDrawForeground(CCanvas canvas) {}

  void requestLayout() {
    if (nodeStatus.inLayout) {
      return;
    }
    markDirty();
    parent?.requestLayout();
  }

  void requestDraw() {
    if (nodeStatus.inDrawing) {
      return;
    }
    markDirty();
    parent?.requestDraw();
  }

  void markDirty() {
    _dirty = true;
    clearCacheLayer();
  }

  void markDirtyWithChild() {
    _dirty = true;
    clearCacheLayer();
  }

  bool get isDirty => _dirty;

  void clearDirty() {
    _dirty = false;
  }

  bool get useSingleLayer => false;

  bool? get clipSelf => null;

  void requestLayoutSelf() {
    if (nodeStatus.inLayout) {
      return;
    }
    markDirty();
    _forceLayout = true;
    layout(left, top, right, bottom);
    requestDraw();
  }

  Rect getGlobalBounds() {
    if (parent == null) {
      return boxBound;
    }
    var boundRect = boxBound;
    Rect parentRect = parent!.getGlobalBounds();
    double l = parentRect.left + boundRect.left;
    double t = parentRect.top + boundRect.top;
    return Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
  }

  bool _show = true;

  bool get isShow => _show;

  bool get notShow => !_show;

  void show() {
    if (_show) {
      return;
    }
    _show = true;
    requestDraw();
  }

  void hide() {
    if (!_show) {
      _show = false;
      requestDraw();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _parent = null;
    layoutParams = const LayoutParams.matchAll();
    cacheLayer.clear();
  }

  ///=========Debug 绘制相关方法===============
  void debugDraw(CCanvas canvas, Offset offset, {Color color = const Color(0xFF673AB7), bool fill = true, num r = 6}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(offset, r.toDouble(), mPaint);
  }

  void debugDrawRect(CCanvas canvas, Rect rect, {Color color = const Color(0xFF673AB7), bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawRect(rect, mPaint);
  }

  void debugDrawRulerLine(CCanvas canvas, {Color color = const Color(0xFF000000)}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawLine(Offset(width / 2, 0), Offset(width / 2, height), mPaint);
    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), mPaint);
  }

  void debugDrawPath(CCanvas canvas, Path path, {Color color = const Color(0xFF673AB7), bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawPath(path, mPaint);
  }
}

enum RenderNodeStatus {
  none,
  measureStart,
  measureEnd,
  layoutStart,
  layoutEnd,
  drawing;

  bool get inMeasure {
    return this == RenderNodeStatus.measureStart;
  }

  bool get inLayout {
    return this == RenderNodeStatus.layoutStart;
  }

  bool get inDrawing {
    return this == RenderNodeStatus.drawing;
  }
}
