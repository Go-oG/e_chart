import 'dart:io';

import 'package:flutter/material.dart';

import '../charts/series.dart';
import '../component/tooltip/context_menu.dart';
import '../component/tooltip/context_menu_builder.dart';
import '../gesture/chart_gesture.dart';
import '../gesture/series_gesture.dart';
import '../model/enums/drag_type.dart';
import '../model/enums/scale_type.dart';
import '../model/string_number.dart';
import '../utils/log_util.dart';
import 'context.dart';
import 'draw_node.dart';
import 'view_group.dart';

abstract class ChartView extends DrawNode implements ToolTipBuilder {
  late Context context;
  LayoutParams layoutParams = LayoutParams.match();
  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);
  Rect oldBoundRect = const Rect.fromLTRB(0, 0, 0, 0); //记录旧的边界位置，实现动画相关的计算
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

  ChartView();

  void attach(Context context, ViewParent parent) {
    this.context = context;
    _parent = parent;
    onAttach();
  }

  void onAttach() {}

  void detach() {
    onDetach();
  }

  void onDetach() {}

  @override
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

  @override
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

  void debugDraw(Canvas canvas, Offset offset) {
    Paint mPaint = Paint();
    mPaint.color = Colors.red;
    mPaint.style = PaintingStyle.fill;
    canvas.drawCircle(offset, 3, mPaint);
  }

  void debugDrawArea(Canvas canvas) {
    Paint mPaint = Paint();
    mPaint.color = Colors.red;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), mPaint);
  }

  void debugDrawRulerLine(Canvas canvas) {
    Paint mPaint = Paint();
    mPaint.color = Colors.red;
    mPaint.style = PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawLine(Offset(width / 2, 0), Offset(width / 2, height), mPaint);
    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), mPaint);
  }

  @mustCallSuper
  @override
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
  final Map<int, VoidCallback> _commandMap = {};

  void clearCommand() {
    _commandMap.clear();
  }

  void registerCommand(int code, VoidCallback callback, [bool allowReplace = true]) {
    var old = _commandMap[code];
    if (old == null || allowReplace) {
      _commandMap[code] = callback;
      return;
    }
    if (!allowReplace) {
      throw FlutterError('not allow replace');
    }
  }

  void removeCommand(int code) {
    _commandMap.remove(code);
  }

  ///绑定Series 主要是将Series相关的命令传递到当前View
  void bindSeriesCommand(covariant ChartSeries series) {
    unBindSeries();
    _series = series;
    series.addListener(_handleCommand);
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.insertData] = onAddDataCommand;
    _commandMap[Command.deleteData] = onDeleteDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onSeriesConfigChangeCommand;
  }

  void unBindSeries() {
    _commandMap.clear();
    _series?.removeListener(_handleCommand);
    _series = null;
  }

  void _handleCommand(Command c) {
    int code = c.code;
    var op = _commandMap[code];
    if (op == null) {
      logPrint('code:$code 无法找到相关的回调');
      return;
    }
    op.call();
  }

  void onInvalidateCommand() {
    invalidate();
  }

  void onRelayoutCommand() {
    requestLayout();
  }

  void onSeriesConfigChangeCommand() {
    ///自身配置改变我们只更新当前的节点布局
    forceLayout = true;
    layout(left, top, right, bottom);
    invalidate();
  }

  void onAddDataCommand() {}

  void onDeleteDataCommand() {}

  void onUpdateDataCommand() {}

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
  void onAttach() {
    super.onAttach();
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
          dragMove(e.offsetFromOrigin);
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
