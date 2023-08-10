import 'dart:io';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class ChartView with ViewStateProvider {
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

  void debugDraw(Canvas canvas, Offset offset, {Color color = Colors.deepPurple, bool fill = true, num r = 6}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(offset, r.toDouble(), mPaint);
  }

  void debugDrawRect(Canvas canvas, Rect rect, {Color color = Colors.deepPurple, bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawRect(rect, mPaint);
  }

  void debugDrawRulerLine(Canvas canvas, {Color color = Colors.black}) {
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

  void debugDrawPath(Canvas canvas, Path path, {Color color = Colors.deepPurple, bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawPath(path, mPaint);
  }

  @mustCallSuper
  void draw(Canvas canvas) {
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
  bool drawSelf(Canvas canvas, ChartViewGroup parent) {
    if (notShow) {
      return false;
    }
    canvas.save();
    canvas.translate(left, top);
    bool? clip = clipSelf;
    if (clip == null) {
      if (_series != null) {
        clip = _series!.clip;
      } else {
        clip = false;
      }
    }
    if (clip) {
      canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    }
    draw(canvas);
    canvas.restore();
    return false;
  }

  bool? get clipSelf => null;

  void onDrawBackground(Canvas canvas) {}

  ///绘制时最先调用的方法，可以在这里面更改相关属性从而实现动画视觉效果
  void onDrawPre() {}

  void onDraw(Canvas canvas) {}

  void onDrawEnd(Canvas canvas) {}

  ///用于ViewGroup覆写
  void dispatchDraw(Canvas canvas) {}

  /// 覆写实现重绘高亮相关的
  void onDrawHighlight(Canvas canvas) {}

  ///实现绘制前景色
  void onDrawForeground(Canvas canvas) {}

  ViewParent? get parent {
    return _parent;
  }

  void invalidate() {
    if (inDrawing) {
      return;
    }
    markDirty(); //标记为需要重绘
    if (_parent == null) {
      debugPrint('重绘失败：Paren is NULL');
    }
    _parent?.parentInvalidate();
  }

  void invalidateWithAnimator() {
    invalidate();
  }

  void requestLayout() {
    if (inLayout) {
      return;
    }
    parent?.requestLayout();
  }

  void layoutSelf() {
    _forceLayout = true;
    layout(left, top, right, bottom);
  }

  void markDirty() {
    _dirty = true;
  }

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
    ChartSeries? series = _series;
    unBindSeries();
    if (series != null) {
      bindSeries(series);
    }
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

  bool get isDirty {
    return _dirty;
  }

  ///分配索引
  ///返回值表示消耗了好多的索引
  int allocateDataIndex(int index) {
    return 0;
  }

  bool ignoreAllocateDataIndex() {
    return false;
  }

  void onContentScrollStart(Offset scroll) {}

  void onContentScrollUpdate(Offset scroll) {}

  void onContentScrollEnd(Offset scroll) {}

  void onContentScaleUpdate(double sx, double sy) {}
}

///实现了一个简易的手势识别器
abstract class GestureView extends ChartView {
  late ChartGesture _gesture;

  @mustCallSuper
  @override
  void onCreate() {
    super.onCreate();
    _gesture = gestureArea;
    onInitGesture(_gesture);
  }

  @mustCallSuper
  @override
  void onLayoutEnd() {
    super.onLayoutEnd();
    onGestureAreaInit(_gesture);
  }

  ChartGesture get gestureArea {
    return RectGesture();
  }

  void onGestureAreaInit(ChartGesture gesture) {
    if (gesture is RectGesture) {
      (gesture).rect = boxBounds;
    }
  }

  Offset _lastHover = Offset.zero;
  Offset _lastDrag = Offset.zero;
  Offset _lastLongPress = Offset.zero;

  void onInitGesture(ChartGesture gesture) {
    gesture.clear();
    context.removeGesture(gesture);
    context.addGesture(gesture);
    if (enableClick) {
      gesture.click = (e) {
        onClick(toLocal(e.globalPosition));
      };
    }
    if (enableDoubleClick) {
      gesture.doubleClick = (e) {
        onDoubleClick(toLocal(e.globalPosition));
      };
    }

    if (enableHover) {
      gesture.hoverStart = (e) {
        _lastHover = toLocal(e.globalPosition);
        onHoverStart(_lastHover);
      };
      gesture.hoverMove = (e) {
        Offset of = toLocal(e.globalPosition);
        onHoverMove(of, _lastHover);
        _lastHover = of;
      };
      gesture.hoverEnd = (e) {
        _lastHover = Offset.zero;
        onHoverEnd();
      };
    }

    if (enableLongPress) {
      gesture.longPressStart = (e) {
        _lastLongPress = toLocal(e.globalPosition);
        onLongPressStart(_lastLongPress);
      };
      gesture.longPressMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastLongPress.dx;
        var dy = offset.dy - _lastLongPress.dy;
        _lastLongPress = offset;
        onLongPressMove(offset, Offset(dx, dy));
      };
      gesture.longPressEnd = () {
        _lastLongPress = Offset.zero;
        onLongPressEnd();
      };
    }

    if (enableDrag) {
      gesture.dragStart = (e) {
        var offset = toLocal(e.globalPosition);
        _lastDrag = offset;
        onDragStart(offset);
      };
      gesture.dragMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastDrag.dx;
        var dy = offset.dy - _lastDrag.dy;
        _lastDrag = offset;
        onDragMove(offset, Offset(dx, dy));
      };
      gesture.dragEnd = () {
        _lastDrag = Offset.zero;
        onDragEnd();
      };
    }

    if (enableScale) {
      gesture.scaleStart = (e) {
        onScaleStart(toLocal(e.globalPosition));
      };
      gesture.scaleUpdate = (e) {
        onScaleUpdate(toLocal(e.focalPoint), e.rotation, e.scale, false);
      };
      gesture.scaleEnd = () {
        onScaleEnd();
      };
    }
  }

  bool get enableClick => true;

  bool get enableDoubleClick => false;

  bool get enableLongPress => false;

  bool get enableHover => !(Platform.isAndroid || Platform.isIOS);

  bool get enableDrag => false;

  bool get enableScale => false;

  void onClick(Offset offset) {}

  void onDoubleClick(Offset offset) {}

  void onHoverStart(Offset offset) {}

  void onHoverMove(Offset offset, Offset last) {}

  void onHoverEnd() {}

  void onLongPressStart(Offset offset) {}

  void onLongPressMove(Offset offset, Offset diff) {}

  void onLongPressEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  void onScaleStart(Offset offset) {}

  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {}

  void onScaleEnd() {}
}

///强制要求提供一个Series和Layout;
///并简单实现了相关的手势操作
abstract class SeriesView<T extends ChartSeries, L extends LayoutHelper> extends GestureView {
  final T series;
  late L layoutHelper;

  SeriesView(this.series);

  @override
  void onCreate() {
    super.onCreate();
    layoutHelper = buildLayoutHelper();
  }

  L buildLayoutHelper();

  @override
  void bindSeries(covariant T series) {
    if (series != this.series) {
      throw FlutterError('Not allow binding different series ');
    }
    super.bindSeries(series);
  }

  @override
  void onDrawBackground(Canvas canvas) {
    Color? color = series.backgroundColor;
    if (color != null) {
      mPaint.reset();
      mPaint.color = color;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(selfBoxBound, mPaint);
    }
  }

  @override
  void onInitGesture(ChartGesture gesture) {
    if (series is SeriesGesture && (series as SeriesGesture).enableSeriesGesture) {
      gesture.clear();
      context.removeGesture(gesture);
      context.addGesture(gesture);
      (series as SeriesGesture).bindGesture(this, gesture);
      return;
    }
    super.onInitGesture(gesture);
  }

  @override
  void onClick(Offset offset) {
    layoutHelper.onClick(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    layoutHelper.onHoverStart(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    layoutHelper.onHoverMove(offset);
  }

  @override
  void onHoverEnd() {
    layoutHelper.onHoverEnd();
  }

  @mustCallSuper
  @override
  void onStart() {
    super.onStart();
    layoutHelper.removeListener(invalidate);
    layoutHelper.addListener(invalidate);
  }

  @mustCallSuper
  @override
  void onStop() {
    layoutHelper.removeListener(invalidate);
    super.onStop();
  }

  ///事件转发
  @override
  void onBrushEvent(BrushEvent event) {
    layoutHelper.onBrushEvent(event);
  }

  @override
  void onBrushClearEvent(BrushClearEvent event) {
    layoutHelper.onBrushClearEvent(event);
  }

  @override
  void onBrushEndEvent(BrushEndEvent event) {
    layoutHelper.onBrushEndEvent(event);
  }

  @override
  void onContentScaleUpdate(double sx, double sy) {
    layoutHelper.onContentScaleUpdate(sx, sy);
  }

  @override
  void onContentScrollEnd(Offset scroll) {
    layoutHelper.onContentScrollEnd(scroll);
  }

  @override
  void onContentScrollStart(Offset scroll) {
    layoutHelper.onContentScrollChange(scroll);
  }

  @override
  void onContentScrollUpdate(Offset scroll) {
    layoutHelper.onContentScrollChange(scroll);
  }
}

abstract class CoordChildView<T extends ChartSeries, L extends LayoutHelper> extends SeriesView<T, L> {
  CoordChildView(super.series);

  @override
  bool get enableDrag => false;

  @override
  bool get enableScale => false;
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
  static const _wrapType = -2;
  static const _matchType = -1;
  static const _normal = 0;
  final SNumber size;
  final int _type;

  const SizeParams(this.size) : _type = _normal;

  const SizeParams.wrap()
      : _type = _wrapType,
        size = SNumber.zero;

  const SizeParams.match()
      : _type = _matchType,
        size = SNumber.zero;

  bool get isWrap {
    return _type == _wrapType;
  }

  bool get isMatch {
    return _type == _matchType;
  }

  bool get isNormal {
    return _type == _normal;
  }

  double convert(num n) {
    return size.convert(n);
  }
}
