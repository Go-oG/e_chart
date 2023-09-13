import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

abstract class ChartView {
  Context? _context;

  Context get context => _context!;

  ///存储当前节点的布局方式
  LayoutParams _layoutParams = const LayoutParams.matchAll();

  LayoutParams get layoutParams => _layoutParams;

  set layoutParams(LayoutParams p) {
    _layoutParams = p;
  }

  ///索引层次
  int zLevel = -1;

  ///存储当前视图在父视图中的位置属性
  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);

  ///记录旧的边界位置，可用于动画相关的计算
  Rect oldBoundRect = const Rect.fromLTRB(0, 0, 0, 0);

  ///记录其全局位置
  Rect _globalBoundRect = Rect.zero;

  ///绘图缓存(可以优化绘制效率)
  LayerHandle<PictureLayer> layerHandle = LayerHandle();

  ViewParent? _parent;
  Paint mPaint = Paint();
  bool inLayout = false;
  bool inDrawing = false;
  bool _dirty = false; // 标记视图区域是否 需要重绘

  @protected
  bool layoutCompleted = false;

  @protected
  bool measureCompleted = false;

  bool _forceLayout = false;

  bool get forceLayout => _forceLayout;

  void setForceLayout() {
    _forceLayout = true;
  }

  @protected
  bool forceMeasure = false;

  final String id = randomId();

  ChartView();

  bool _show = true;

  bool get isShow => _show;

  bool get notShow => !_show;

  void show() {
    if (_show) {
      return;
    }
    _show = true;
    invalidate();
  }

  void hide() {
    if (!_show) {
      _show = false;
      invalidate();
    }
  }

  //=========生命周期回调方法开始==================
  ///由Context负责回调
  ///该回调只会发生在视图创建后，且只会回调一次
  ///绝大部分子类都不应该覆写该方法
  void create(Context context, ViewParent parent) {
    _context = context;
    _parent = parent;
    onCreate();
  }

  ///创建后的回调，在该方法后可以安全的使用Context
  void onCreate() {}

  ///视图进入已开始状态
  void onStart() {}

  ///视图进入停止状态
  void onStop() {}

  ///由Context负责回调
  ///当该方法被调用时标志着当前View即将被销毁
  ///你可以在这里进行资源释放等操作
  void destroy() {
    layerHandle.layer == null;
    unBindSeries();
    onDestroy();
    _context = null;
  }

  void onDestroy() {}

  ///=======Brush事件通知=======
  void onBrushEvent(BrushEvent event) {}

  void onBrushEndEvent(BrushEndEvent event) {}

  void onBrushClearEvent(BrushClearEvent event) {}

  //=======布局测量相关方法==============
  void measure(double parentWidth, double parentHeight) {
    bool force = forceMeasure || forceLayout;
    bool minDiff =
        (boundRect.width - parentWidth).abs() <= 0.00001 && (boundRect.height - parentHeight).abs() <= 0.00001;
    if (measureCompleted && minDiff && !force) {
      return;
    }
    oldBoundRect = boundRect;
    Size size = onMeasure(parentWidth, parentHeight);
    boundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    measureCompleted = true;
  }

  Size onMeasure(double parentWidth, double parentHeight) {
    double w = 0;
    double h = 0;
    LayoutParams lp = layoutParams;

    if (lp.width.isMatch) {
      w = parentWidth;
    } else if (lp.width.isWrap) {
      w = 0;
    } else {
      w = lp.width.convert(parentWidth);
    }
    if (lp.height.isMatch) {
      h = parentHeight;
    } else if (lp.height.isWrap) {
      h = 0;
    } else {
      h = lp.height.convert(parentHeight);
    }
    w += lp.padding.horizontal;
    h += lp.padding.vertical;
    return Size(w, h);
  }

  void layout(double left, double top, double right, double bottom) {
    if (layoutCompleted && !forceLayout) {
      bool b1 = (left - boundRect.left).abs() < 1;
      bool b2 = (top - boundRect.top).abs() < 1;
      bool b3 = (right - boundRect.right).abs() < 1;
      bool b4 = (bottom - boundRect.bottom).abs() < 1;
      if (b1 && b2 && b3 && b4) {
        return;
      }
    }
    if (inLayout) {
      return;
    }
    inLayout = true;
    oldBoundRect = boundRect;
    boundRect = Rect.fromLTRB(left, top, right, bottom);

    if (parent == null) {
      _globalBoundRect = boundRect;
    } else {
      Rect parentRect = parent!.getGlobalAreaBounds();
      double l = parentRect.left + boundRect.left;
      double t = parentRect.top + boundRect.top;
      _globalBoundRect = Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
    }
    onLayout(left, top, right, bottom);
    inLayout = false;
    _forceLayout = false;
    layoutCompleted = true;
    onLayoutEnd();
  }

  void onLayout(double left, double top, double right, double bottom) {}

  void onLayoutEnd() {}

  @mustCallSuper
  void draw(CCanvas canvas) {
    inDrawing = true;
    if (notShow) {
      inDrawing = false;
      return;
    }
    onDrawPre();
    onDrawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    onDrawEnd(canvas);
    onDrawHighlight(canvas);
    onDrawForeground(canvas);
    inDrawing = false;
  }

  @protected
  bool drawSelf(CCanvas canvas, ChartViewGroup parent) {
    if (notShow) {
      return false;
    }

    _drawInner(canvas, Offset(left, top));

    // var layer = layerHandle.layer;
    // if (useSingleLayer && layer != null && layer.picture != null && this is! ChartViewGroup && !isDirty) {
    //   canvas.paintContext.addLayer(layer);
    //   return true;
    // }
    //
    // layerHandle.layer = null;
    //
    // if (!useSingleLayer) {
    //   _drawInner(canvas, Offset(left, top));
    //   return false;
    // }
    //
    // if (this is ChartViewGroup) {
    //   var offsetLayer = OffsetLayer();
    //   canvas.paintContext.pushLayer(offsetLayer, (context, offset) {
    //     _drawInner(CCanvas(context), offset);
    //   }, globalBoxBound.topLeft);
    // } else {
    //   var record = PictureRecorder();
    //   _drawInner(CCanvas(canvas.paintContext, Canvas(record)), Offset(left, top));
    //   var pic = PictureLayer(selfBoxBound);
    //   pic.isComplexHint = true;
    //   layerHandle.layer = pic;
    //   pic.picture = record.endRecording();
    //   pic.willChangeHint = true;
    //   canvas.paintContext.addLayer(pic);
    // }
    return false;
  }

  void _drawInner(CCanvas canvas, Offset offset) {
    int old = canvas.getSaveCount();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    draw(canvas);
    canvas.restore();
    int nc = canvas.getSaveCount();
    if (nc != old) {
      throw ChartError("$runtimeType Canvas SaveCount error(old:$old new:$nc)");
    }
  }

  void invalidate() {
    markDirty();
    if (inDrawing) {
      return;
    }
    _parent?.parentInvalidate();
  }

  void markDirty() {
    _dirty = true;
    layerHandle.layer = null;
  }

  void requestLayout() {
    markDirty();
    if (inLayout) {
      return;
    }
    parent?.requestLayout();
  }

  void layoutSelf() {
    markDirty();
    if (inLayout) {
      return;
    }
    _forceLayout = true;
    layout(left, top, right, bottom);
    invalidate();
  }

  bool get useSingleLayer => false;

  bool? get clipSelf => null;

  void onDrawBackground(CCanvas canvas) {}

  ///绘制时最先调用的方法，可以在这里面更改相关属性从而实现动画视觉效果
  void onDrawPre() {}

  void onDraw(CCanvas canvas) {}

  void onDrawEnd(CCanvas canvas) {}

  ///用于ViewGroup覆写
  void dispatchDraw(CCanvas canvas) {}

  /// 覆写实现重绘高亮相关的
  void onDrawHighlight(CCanvas canvas) {}

  ///实现绘制前景色
  void onDrawForeground(CCanvas canvas) {}

  ViewParent? get parent {
    return _parent;
  }

  bool get isDirty => _dirty;

  void clearDirty() {
    _dirty = false;
  }

  ///=============处理Series和其绑定时相关的操作=============
  ChartSeries? _series;

  ///存储命令执行相关的操作
  final Map<Command, VoidFun1<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap.clear();
  }

  void registerCommand(Command c, VoidFun1<Command> callback, [bool allowReplace = true]) {
    var old = _commandMap[c];
    if (!allowReplace && callback != old) {
      throw ChartError('not allow replace');
    }
    _commandMap[c] = callback;
  }

  void removeCommand(int code) {
    _commandMap.remove(code);
  }

  ///绑定Series 主要是将Series相关的命令传递到当前View
  VoidCallback? _defaultCommandCallback;

  void bindSeries(covariant ChartSeries series) {
    unBindSeries();
    _series = series;
    _defaultCommandCallback = () {
      onReceiveCommand(_series?.value);
    };
    series.addListener(_defaultCommandCallback!);
    registerCommandHandler();
  }

  void unBindSeries() {
    _commandMap.clear();
    if (_defaultCommandCallback != null) {
      _series?.removeListener(_defaultCommandCallback!);
    }
    _series = null;
  }

  void registerCommandHandler() {
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onSeriesConfigChangeCommand;
  }

  void unregisterCommandHandler() {
    _commandMap.remove(Command.updateData);
    _commandMap.remove(Command.invalidate);
    _commandMap.remove(Command.reLayout);
    _commandMap.remove(Command.configChange);
  }

  void onReceiveCommand(covariant Command? c) {
    if (c == null) {
      return;
    }

    var op = _commandMap[c];
    if (op == null) {
      Logger.w('$c 无法找到能出来该命令相关的回调');
      return;
    }
    try {
      op.call(c);
    } catch (e) {
      Logger.e(e);
    }
  }

  void onInvalidateCommand(covariant Command c) {
    invalidate();
  }

  void onRelayoutCommand(covariant Command c) {
    requestLayout();
  }

  void onSeriesConfigChangeCommand(covariant Command c) {
    ///自身配置改变我们只更新当前的配置和节点布局
    _forceLayout = true;
    onStop();
    onStart();
    layout(left, top, right, bottom);
    invalidate();
  }

  void onUpdateDataCommand(covariant Command c) {}

  /// ====================普通属性函数=======================================

  double get width => boundRect.width;

  double get height => boundRect.height;

  // 返回当前View在父Parent中的位置坐标
  double get left => boundRect.left;

  double get top => boundRect.top;

  double get right => boundRect.right;

  double get bottom => boundRect.bottom;

  // 返回自身的中心点坐标
  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  //返回其矩形边界
  Rect get boxBounds => boundRect;

  Rect get globalBoxBound => _globalBoundRect;

  Rect get selfBoxBound => Rect.fromLTWH(0, 0, width, height);

  Offset toLocal(Offset global) {
    return Offset(global.dx - _globalBoundRect.left, global.dy - _globalBoundRect.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + _globalBoundRect.left, local.dy + _globalBoundRect.top);
  }

  ///分配索引
  ///返回值表示消耗了好多的索引
  int allocateDataIndex(int index) {
    return 0;
  }

  ///是否忽略索引分配
  bool ignoreAllocateDataIndex() {
    return false;
  }

  ///=======由坐标系回调=========
  void onCoordScrollStart(CoordScroll scroll) {}

  void onCoordScrollUpdate(CoordScroll scroll) {}

  void onCoordScrollEnd(CoordScroll scroll) {}

  void onCoordScaleStart(CoordScale scale) {}

  void onCoordScaleUpdate(CoordScale scale) {}

  void onCoordScaleEnd(CoordScale scale) {}

  void onLayoutByParent(LayoutType type) {}

  ///=====Debug 相关方法===============
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

class LayoutParams {
  final SizeParams width;
  final SizeParams height;

  final EdgeInsets margin;
  final EdgeInsets padding;

  const LayoutParams(
    this.width,
    this.height, {
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  });

  const LayoutParams.matchAll({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  })  : width = const SizeParams.match(),
        height = const SizeParams.match();

  const LayoutParams.wrapAll({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  })  : width = const SizeParams.wrap(),
        height = const SizeParams.wrap();
}

class SizeParams {
  static const wrapType = -2;
  static const matchType = -1;
  static const _normal = 0;
  final SNumber size;
  final int _type;

  static SizeParams from(SNumber sn) {
    if (sn.number == wrapType) {
      return const SizeParams.wrap();
    }
    if (sn.number == SizeParams.matchType || sn.number <= 0) {
      return const SizeParams.match();
    }
    return SizeParams(sn);
  }

  const SizeParams(this.size) : _type = _normal;

  const SizeParams.wrap()
      : _type = wrapType,
        size = SNumber.zero;

  const SizeParams.match()
      : _type = matchType,
        size = SNumber.zero;

  bool get isWrap {
    return _type == wrapType;
  }

  bool get isMatch {
    return _type == matchType;
  }

  bool get isNormal {
    return _type == _normal;
  }

  double convert(num n) {
    return size.convert(n);
  }
}
