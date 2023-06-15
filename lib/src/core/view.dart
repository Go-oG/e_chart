import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../functions.dart';
import '../model/chart_error.dart';
import '../utils/uuid_util.dart';
import 'command.dart';
import 'series.dart';
import '../component/tooltip/context_menu.dart';
import '../component/tooltip/context_menu_builder.dart';
import '../gesture/chart_gesture.dart';
import '../gesture/series_gesture.dart';
import '../model/enums/drag_type.dart';
import '../model/enums/scale_type.dart';
import '../model/string_number.dart';
import '../utils/log_util.dart';
import 'context.dart';
import 'view_group.dart';

abstract class ChartView implements ToolTipBuilder {
  Context? _context;
  LayoutParams layoutParams = LayoutParams.match();
  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);

  //记录旧的边界位置，可用于动画相关的计算
  Rect oldBoundRect = const Rect.fromLTRB(0, 0, 0, 0);
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

  @protected
  bool forceLayout = false;

  @protected
  bool forceMeasure = false;

  late final String id;

  ChartView(){
    id=randomId();
  }

  Context get context => _context!;

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

  //=========生命周期回调方法结束==================

  void measure(double parentWidth, double parentHeight) {
    bool force = forceMeasure || forceLayout;
    bool minDiff = (boundRect.width - parentWidth).abs() <= 0.00001 && (boundRect.height - parentHeight).abs() <= 0.00001;
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
    num wn = lp.width.number;
    if (wn == LayoutParams.matchParent) {
      w = parentWidth;
    } else if (wn == LayoutParams.wrapContent) {
      w = 0;
    } else if (wn >= 0) {
      w = lp.width.convert(parentWidth);
    } else {
      w = parentWidth;
    }
    num hn = lp.height.number;
    if (hn == LayoutParams.matchParent) {
      h = parentHeight;
    } else if (hn == LayoutParams.wrapContent) {
      h = 0;
    } else if (hn >= 0) {
      h = lp.height.convert(parentHeight);
    } else {
      h = parentHeight;
    }
    w += lp.leftPadding.convert(parentWidth) + lp.rightPadding.convert(parentWidth);
    h += lp.topPadding.convert(parentHeight) + lp.bottomPadding.convert(parentHeight);
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
    forceLayout = false;
    layoutCompleted = true;
    onLayoutEnd();
  }

  void onLayout(double left, double top, double right, double bottom) {}

  void onLayoutEnd() {}

  void debugDraw(Canvas canvas, Offset offset, {Color color = Colors.deepPurple, bool fill = true,num r=6}) {
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

  @mustCallSuper
  void draw(Canvas canvas) {
    inDrawing = true;
    onDrawPre();
    drawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    onDrawEnd(canvas);
    onDrawHighlight(canvas);
    onDrawForeground(canvas);
    inDrawing = false;
  }

  @protected
  bool drawSelf(Canvas canvas, ChartViewGroup parent) {
    computeScroll();
    canvas.save();
    canvas.translate(left, top);
    if (_series != null && _series!.clip) {
      canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    }
    draw(canvas);
    canvas.restore();
    return false;
  }

  void drawBackground(Canvas canvas) {}

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

  void markDirty() {
    _dirty = true;
  }

  void clearDirty() {
    _dirty = false;
  }

  ///======================处理ToolTip========================

  @override
  ContextMenu? onCreatedContextMenu() {
    return null;
  }

  @override
  Offset onMenuPosition() {
    return Offset.zero;
  }

  ///=============处理Series和其绑定时相关的操作=============
  ChartSeries? _series;

  ///存储命令执行相关的操作
  final Map<Command, ValueCallback<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap.clear();
  }

  void registerCommand(Command c, ValueCallback<Command> callback, [bool allowReplace = true]) {

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

  void bindSeriesCommand(covariant ChartSeries series) {
    unBindSeries();
    _series = series;
    _defaultCommandCallback = () {
      onReceiveCommand(_series?.value);
    };
    series.addListener(_defaultCommandCallback!);
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.insertData] = onAddDataCommand;
    _commandMap[Command.deleteData] = onDeleteDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onSeriesConfigChangeCommand;
  }

  void unBindSeries() {
    _commandMap.clear();
    if (_defaultCommandCallback != null) {
      _series?.removeListener(_defaultCommandCallback!);
    }
    _series = null;
  }

  void onReceiveCommand(covariant Command? c) {
    if (c == null) {
      return;
    }

    var op = _commandMap[c];
    if (op == null) {
      logPrint('$c 无法找到能出来该命令相关的回调');
      return;
    }
    try {
      op.call(c);
    } catch (e) {
      logPrint('$e');
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
    forceLayout = true;
    onStop();
    onStart();
    layout(left, top, right, bottom);
    invalidate();
  }

  void onAddDataCommand(covariant Command c) {}

  void onDeleteDataCommand(covariant Command c) {}

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
  Rect get areaBounds => boundRect;

  Rect get globalAreaBound => _globalBoundRect;

  Offset toLocalOffset(Offset globalOffset) {
    return Offset(globalOffset.dx - _globalBoundRect.left, globalOffset.dy - _globalBoundRect.top);
  }

  Offset toGlobalOffset(Offset localOffset) {
    return Offset(localOffset.dx + _globalBoundRect.left, localOffset.dy + _globalBoundRect.top);
  }

  bool get isDirty {
    return _dirty;
  }

  void computeScroll() {}
}

///强制要求提供一个Series;
///并简单实现了相关的手势操作
abstract class SeriesView<T extends ChartSeries> extends ChartView {
  final T series;
  final RectGesture _gesture = RectGesture();

  SeriesView(this.series);

  @override
  void bindSeriesCommand(covariant T series) {
    if (series != this.series) {
      throw FlutterError('Not allow binding different series ');
    }
    super.bindSeriesCommand(series);
  }

  @mustCallSuper
  @override
  void onCreate() {
    super.onCreate();
    _initGesture();
  }

  @mustCallSuper
  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _gesture.rect = areaBounds;
  }

  Offset _lastHover = Offset.zero;

  Offset _lastDrag = Offset.zero;

  void _initGesture() {
    _gesture.clear();
    context.removeGesture(_gesture);
    context.addGesture(_gesture);
    if (series is SeriesGesture && (series as SeriesGesture).enableSeriesGesture) {
      (series as SeriesGesture).bindGesture(this, _gesture);
      return;
    }
    if (enableClick) {
      _gesture.click = (e) {
        onClick(toLocalOffset(e.globalPosition));
      };
    }
    if (enableHover) {
      _gesture.hoverStart = (e) {
        _lastHover = toLocalOffset(e.globalPosition);
        onHoverStart(_lastHover);
      };
      _gesture.hoverMove = (e) {
        Offset of = toLocalOffset(e.globalPosition);
        onHoverMove(of, _lastHover);
        _lastHover = of;
      };
      _gesture.hoverEnd = (e) {
        _lastHover = Offset.zero;
        onHoverEnd();
      };
    }
    if (enableDrag) {
      dragStart(Offset offset) {
        _lastDrag = offset;
        onDragStart(offset);
      }

      dragMove(Offset offset) {
        var dx = offset.dx - _lastDrag.dx;
        var dy = offset.dy - _lastDrag.dy;
        _lastDrag = offset;
        onDragMove(offset, Offset(dx, dy));
      }

      dragCancel() {
        _lastDrag = Offset.zero;
        onDragEnd();
      }

      if (context.config.dragType == DragType.longPress) {
        _gesture.longPressStart = (e) {
          dragStart(toLocalOffset(e.globalPosition));
        };
        _gesture.longPressMove = (e) {
          dragMove(toLocalOffset(e.globalPosition));
        };
        _gesture.longPressEnd = (e) {
          dragCancel();
        };
        _gesture.longPressCancel = () {
          dragCancel();
        };
      } else {
        _gesture.horizontalDragStart = (e) {
          dragStart(toLocalOffset(e.globalPosition));
        };
        _gesture.horizontalDragMove = (e) {
          dragMove(toLocalOffset(e.globalPosition));
        };
        _gesture.horizontalDragEnd = (e) {
          dragCancel();
        };
        _gesture.horizontalDragCancel = dragCancel;
        _gesture.verticalDragStart = (e) {
          dragStart(toLocalOffset(e.globalPosition));
        };
        _gesture.verticalDragMove = (e) {
          dragMove(toLocalOffset(e.globalPosition));
        };
        _gesture.verticalDragEnd = (e) {
          dragCancel();
        };
        _gesture.verticalDragCancel = dragCancel;
      }
    }
    if (enableScale) {
      if (context.config.scaleType == ScaleType.doubleTap) {
        _gesture.doubleClickDown = (e) {
          onScaleStart(toLocalOffset(e.globalPosition));
        };
        _gesture.doubleClickCancel = () {
          onScaleEnd();
        };
        _gesture.doubleClick = (e) {
          ///双击放大的递增量(0.25)
          onScaleUpdate(toLocalOffset(e.globalPosition), 0, 0.25, 0.25, 0.25, true);
        };
      } else {
        _gesture.scaleStart = (e) {
          onScaleStart(toLocalOffset(e.globalPosition));
        };
        _gesture.scaleUpdate = (e) {
          onScaleUpdate(toLocalOffset(e.globalPosition), e.rotation, e.scale, e.horizontalScale, e.verticalScale, false);
        };
        _gesture.scaleEnd = (e) {
          onScaleEnd();
        };
        _gesture.scaleCancel = () {
          onScaleEnd();
        };
      }
    }
  }

  bool get enableHover => series.enableHover ?? !(Platform.isAndroid || Platform.isIOS);

  bool get enableDrag => series.enableDrag ?? true;

  bool get enableClick => series.enableClick ?? true;

  bool get enableScale => series.enableScale ?? false;

  void onClick(Offset offset) {}

  void onHoverStart(Offset offset) {}

  void onHoverMove(Offset offset, Offset last) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  void onScaleStart(Offset offset) {}

  void onScaleUpdate(Offset offset, double rotation, double scale, double hScale, double vScale, bool doubleClick) {}

  void onScaleEnd() {}
}

class LayoutParams {
  static const int matchParent = -1;
  static const int wrapContent = -2;

  final SNumber width;
  final SNumber height;

  final SNumber leftMargin;
  final SNumber topMargin;
  final SNumber rightMargin;
  final SNumber bottomMargin;

  final SNumber leftPadding;
  final SNumber topPadding;
  final SNumber rightPadding;
  final SNumber bottomPadding;

  LayoutParams(
    this.width,
    this.height, {
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.leftPadding = SNumber.zero,
    this.topPadding = SNumber.zero,
    this.rightPadding = SNumber.zero,
    this.bottomPadding = SNumber.zero,
  });

  LayoutParams.match()
      : width = const SNumber.number(matchParent),
        height = const SNumber.number(matchParent),
        leftMargin = SNumber.zero,
        topMargin = SNumber.zero,
        rightMargin = SNumber.zero,
        bottomMargin = SNumber.zero,
        leftPadding = SNumber.zero,
        topPadding = SNumber.zero,
        rightPadding = SNumber.zero,
        bottomPadding = SNumber.zero;

  LayoutParams.wrap()
      : width = const SNumber.number(wrapContent),
        height = const SNumber.number(wrapContent),
        leftMargin = SNumber.zero,
        topMargin = SNumber.zero,
        rightMargin = SNumber.zero,
        bottomMargin = SNumber.zero,
        leftPadding = SNumber.zero,
        topPadding = SNumber.zero,
        rightPadding = SNumber.zero,
        bottomPadding = SNumber.zero;
}
