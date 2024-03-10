import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/model/cache_layer.dart';
import 'package:e_chart/src/model/chart_edgeinset.dart';
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

  ///测量视图 当测量完成后应该知道视图的宽度 高度 间距等信息
  void measure(double parentWidth, double parentHeight) {
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
      w = padding.horizontal;
    } else {
      padding.left = lp.getLeftPadding(w);
      padding.right = lp.getRightPadding(w);
    }
    if (lp.height.isWrap) {
      padding.top = lp.getTopPadding(parentHeight);
      padding.bottom = lp.getBottomPadding(parentHeight);
      h = padding.vertical;
    } else {
      padding.top = lp.getTopPadding(h);
      padding.bottom = lp.getBottomPadding(h);
    }
    margin.top = lp.getTopMargin(parentHeight);
    margin.left = lp.getLeftMargin(parentWidth);
    margin.right = lp.getRightMargin(parentWidth);
    margin.bottom = lp.getBottomMargin(parentHeight);
    return Size(w, h);
  }

  ///记录布局次数
  int _layoutCount = 0;

  void layout(double left, double top, double right, double bottom) {
    if (nodeStatus.inLayout) {
      Logger.i("$runtimeType 当前正在布局中 放弃布局");
      return;
    }
    nodeStatus = RenderNodeStatus.layoutStart;
    forceLayout = false;
    _layoutCount++;
    oldBound = boxBound;
    boxBound = Rect.fromLTRB(left, top, right, bottom);
    globalBound = getGlobalBounds();

    onLayout(left, top, right, bottom);
    nodeStatus = RenderNodeStatus.layoutEnd;
    onLayoutComplete();
  }

  bool get isFirstLayout => _layoutCount == 1;

  void onLayout(double left, double top, double right, double bottom) {}

  void onLayoutComplete() {}

  void clearCacheLayer() {
    cacheLayer.clear();
  }

  void draw(CCanvas canvas) {
    clearDirty();
    if (notShow) {
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
    clearDirty();
    if (notShow) {
      return false;
    }

    _drawSelf(canvas);
    return true;

    // var layer = cacheLayer.layer;
    // final notChange = cacheLayer.notChange(width, height, translationX, translationY, scaleX, scaleY);
    // if (useSingleLayer && layer != null && !dirty && notChange) {
    //   canvas.paintContext.addLayer(layer);
    //   return true;
    // }
    //
    // if (!useSingleLayer) {
    //   _drawSelf(canvas, Offset(left, top), true);
    //   return false;
    // }
    //
    // var oldLayer = layer;
    //
    // var newLayer = canvas.paintContext.pushClipRect(
    //   true,
    //   globalBound.topLeft,
    //   Rect.fromLTWH(0, 0, width, height),
    //   (context, offset) {
    //     _drawSelf(CCanvas.fromPaintingContext(context), offset, true);
    //   },
    //   oldLayer: oldLayer as ClipRectLayer?,
    // );
    // cacheLayer.saveByView(newLayer, this);
    //
    // return false;
  }

  void _drawSelf(CCanvas canvas) {
    canvas.save();
    bool hasSave = false;
    if (translationX != 0 || translationY != 0 || scrollX != 0 || scrollY != 0 || scaleX != 1 || scaleY != 1) {
      hasSave = true;
      var offsetX = left + translationX + scrollX;
      var offsetY = top + translationY + scrollY;
      canvas.save();
      canvas.translate(offsetX, offsetY);
    }
    if (clipSelf) {
      if (!hasSave) {
        hasSave = true;
        canvas.save();
      }
      canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    }

    draw(canvas);
    if (hasSave) {
      canvas.restore();
    }
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

  bool get clipSelf => false;

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
    cacheLayer.clear();
  }

  void resetLayoutInfo() {
    boxBound = Rect.zero;
    globalBound = Rect.zero;
    oldBound = Rect.zero;
    margin.reset();
    padding.reset();
    translationX = translationY = 0;
    scaleX = scaleY = 1;
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

///存储View的基本信息
mixin ViewAttr {
  ///存储当前节点的布局属性
  LayoutParams layoutParams = const LayoutParams.wrapAll();

  ///存储当前视图在父视图中的位置属性
  Rect boxBound = Rect.zero;

  ///记录其全局位置
  Rect globalBound = Rect.zero;

  ///记录旧的边界位置，可用于动画相关的计算
  Rect oldBound = Rect.zero;

  final ChartEdgeInset margin = ChartEdgeInset();

  final ChartEdgeInset padding = ChartEdgeInset();

  Offset toLocal(Offset global) {
    return Offset(global.dx - globalBound.left, global.dy - globalBound.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + globalBound.left, local.dy + globalBound.top);
  }

  double get width => right - left;

  double get height => bottom - top;

  double get left => boxBound.left;

  double get top => boxBound.top;

  double get right => boxBound.right;

  double get bottom => boxBound.bottom;

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  Rect get selfBoxBound => Rect.fromLTWH(0, 0, width, height);

  Size get size => Size(width, height);

  double translationX = 0;

  double translationY = 0;

  Offset get translation => Offset(translationX, translationY);

  double scaleX = 1;

  double scaleY = 1;

  Offset get scale => Offset(scaleX, scaleY);

  double scrollX = 0;

  double scrollY = 0;

  Offset get scroll => Offset(scrollX, scrollY);

  bool visibility=true;

  void resetTranslation() {
    translationX = translationY = 0;
  }

  void resetScale() {
    scaleX = scaleY = 1;
  }

  void resetMarginAndPadding() {
    padding.reset();
    margin.reset();
  }


}
