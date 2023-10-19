import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

///用于辅助布局相关的抽象类，通常和SeriesView 配合使用
///其包含了Chart事件分发、处理以及手势等相关处理
abstract class LayoutHelper<S extends ChartSeries> extends ChartNotifier<Command> {
  Context? _context;

  Context get context {
    var c = _context;
    if (c == null) {
      throw ChartError("Context is Null, This LayoutHelper($runtimeType) maybe dispose");
    }
    return c;
  }

  set context(Context c) => _context = c;

  S? _series;

  set series(S s) => _series = s;

  S get series {
    var s = _series;
    if (s == null) {
      throw ChartError("Series is Null, This LayoutHelper($runtimeType) maybe dispose");
    }
    return s;
  }

  ChartView? _view;

  ChartView get view => _view!;

  set view(ChartView? v) => _view = v;

  void clearRef() {
    clearListener();
    _series = null;
    _context = null;
    _view = null;
  }

  ///布局边界
  Rect boxBound = Rect.zero;
  Rect globalBoxBound = Rect.zero;

  ///标识是否在运行动画
  bool inAnimation = false;

  ///控制在动画期间是否允许手势
  bool allowGestureInAnimation = false;

  ///手势相关的中间量

  ///构造函数
  LayoutHelper(Context context, ChartView view, S series, {bool equalsObject = false})
      : super(Command.none, equalsObject) {
    _context = context;
    _series = series;
    _view = view;
  }

  ///该构造方法用于在无法马上初始化时使用
  ///一般用于Graph等存在多个Layout方式的视图中
  LayoutHelper.lazy({bool equalsObject = false}) : super(Command.none, equalsObject);

  ///==========布局测量相关===========
  void doMeasure(double parentWidth, double parentHeight) {
    this.boxBound = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
    onMeasure();
  }

  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    this.boxBound = boxBound;
    this.globalBoxBound = globalBoxBound;
    onLayout(type);
  }

  void onLayout(LayoutType type);

  void onMeasure() {}

  void stopLayout() {}

  @override
  void dispose() {
    unsubscribeLegendEvent();
    unsubscribeBrushEvent();
    unsubscribeAxisChangeEvent();
    unsubscribeAxisScrollEvent();
    _view = null;
    _series = null;
    _context = null;
    super.dispose();
  }

  ///=========手势处理================
  void onClick(Offset localOffset) {}

  void onHoverStart(Offset localOffset) {}

  void onHoverMove(Offset localOffset) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    notifyLayoutUpdate();
  }

  void onDragEnd() {}

  ///==============事件发送============
  void sendClickEvent(Offset offset, DataNode node, [ComponentType componentType = ComponentType.series]) {
    if (context.hasEventListener(EventType.click)) {
      var event = UserClickEvent(offset, toGlobal(offset), buildEvent(node, componentType));
      context.dispatchEvent(event);
    }
  }

  bool equalsEvent(EventInfo old, DataNode node, ComponentType type) {
    return old.seriesIndex == series.seriesIndex &&
        old.componentType == type &&
        old.data == node.data &&
        old.dataType == node.dataType &&
        old.dataIndex == node.dataIndex &&
        old.node == node &&
        old.groupIndex == node.groupIndex &&
        old.seriesType == series.seriesType;
  }

  void sendHoverStartEvent(Offset offset, DataNode node, [ComponentType componentType = ComponentType.series]) {
    if (!context.hasEventListener(EventType.hoverStart)) {
      return;
    }
    context.dispatchEvent(UserHoverStartEvent(offset, toGlobal(offset), buildEvent(node, componentType)));
  }

  UserHoverUpdateEvent? _lastHoverEvent;

  void sendHoverEvent(Offset offset, DataNode node, [ComponentType componentType = ComponentType.series]) {
    if (context.hasEventListener(EventType.hoverUpdate)) {
      var lastEvent = _lastHoverEvent;
      UserHoverUpdateEvent? event;
      if (lastEvent != null) {
        var old = lastEvent.event;
        if (equalsEvent(old, node, componentType)) {
          event = lastEvent;
          event.localOffset = offset;
          event.globalOffset = toGlobal(offset);
        }
      }
      event ??= UserHoverUpdateEvent(
        offset,
        toGlobal(offset),
        buildEvent(node, componentType),
      );
      _lastHoverEvent = event;
      context.dispatchEvent(event);
    }
  }

  void sendHoverEndEvent(DataNode node, [ComponentType componentType = ComponentType.series]) {
    if (!context.hasEventListener(EventType.hoverEnd)) {
      return;
    }
    context.dispatchEvent(UserHoverEndEvent(buildEvent(node, componentType)));
  }

  EventInfo buildEvent(DataNode node, [ComponentType componentType = ComponentType.series]) {
    return EventInfo(
      componentType: componentType,
      data: node.data,
      node: node,
      dataIndex: node.dataIndex,
      dataType: node.dataType,
      groupIndex: node.groupIndex,
      seriesType: series.seriesType,
      seriesIndex: series.seriesIndex,
    );
  }

  void onSeriesDataUpdate() {
    onLayout(LayoutType.update);
    notifyLayoutUpdate();
  }

  ///========查找坐标系函数=======================

  GridCoord findGridCoord() {
    return context.findGridCoord(series.gridIndex);
  }

  GridCoord? findGridCoordNull() {
    return context.findGridCoordNull(series.gridIndex);
  }

  GridAxis findGridAxis(int index, bool isXAxis) {
    return findGridCoord().getAxis(index, isXAxis);
  }

  PolarCoord findPolarCoord() {
    return context.findPolarCoord(series.polarIndex);
  }

  PolarCoord? findPolarCoordNull() {
    return context.findPolarCoordNull(series.polarIndex);
  }

  CalendarCoord findCalendarCoord() {
    return context.findCalendarCoord(series.calendarIndex);
  }

  CalendarCoord? findCalendarCoordNull() {
    return context.findCalendarCoordNull(series.calendarIndex);
  }

  ParallelCoord findParallelCoord() {
    return context.findParallelCoord(series.parallelIndex);
  }

  ParallelCoord? findParallelCoordNull() {
    return context.findParallelCoordNull(series.parallelIndex);
  }

  RadarCoord findRadarCoord() {
    return context.findRadarCoord(series.radarIndex);
  }

  RadarCoord? findRadarCoordNull() {
    return context.findRadarCoordNull(series.radarIndex);
  }

  ///========通知布局节点刷新=======
  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  ///========坐标转换=======
  Offset toLocal(Offset global) {
    return Offset(global.dx - globalBoxBound.left, global.dy - globalBoxBound.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + globalBoxBound.left, local.dy + globalBoxBound.top);
  }

  Rect getViewPortRect() {
    return Rect.fromLTWH(-translationX, -translationY, width, height);
  }

  ///获取平移偏移量
  Offset getTranslation() {
    var type = series.coordType;
    if (type == CoordType.polar) {
      return findPolarCoord().translation;
    }
    if (type == CoordType.calendar) {
      return findCalendarCoord().translation;
    }
    if (type == CoordType.radar) {
      return findRadarCoord().translation;
    }
    if (type == CoordType.parallel) {
      return findParallelCoord().translation;
    }
    if (type == CoordType.grid) {
      return findGridCoord().translation;
    }
    return view.translation;
  }

  double get translationX => view.translationX;

  set translationX(num x) => view.translationX = x.toDouble();

  double get translationY => view.translationY;

  set translationY(num y) => view.translationY = y.toDouble();

  void resetTranslation() => view.translationX = view.translationY = 0;

  double get width => boxBound.width;

  double get height => boxBound.height;

  ///获取裁剪路径
  Rect getClipRect(Direction direction, [double animationPercent = 1]) {
    if (animationPercent > 1) {
      animationPercent = 1;
    }
    if (animationPercent < 0) {
      animationPercent = 0;
    }
    if (direction == Direction.horizontal) {
      return Rect.fromLTWH(translationX.abs(), translationY.abs(), width * animationPercent, height);
    } else {
      return Rect.fromLTWH(translationX.abs(), translationY.abs(), width, height * animationPercent);
    }
  }

  ///获取动画运行配置(可以为空)
  AnimatorOption? getAnimation(LayoutType type, [int count = -1]) {
    var attr = series.animation ?? context.option.animation;
    if (type == LayoutType.none || attr == null) {
      return null;
    }
    if (count > 0 && count > attr.threshold && attr.threshold > 0) {
      return null;
    }
    if (type == LayoutType.layout) {
      if (attr.duration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    if (type == LayoutType.update) {
      if (attr.updateDuration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    return null;
  }

  ///注册Brush组件 Event监听器

  void subscribeBrushEvent() {
    _context?.addEventCall(EventType.brushStart, onBrushStart as VoidFun1<ChartEvent>);
    _context?.addEventCall(EventType.brushUpdate, onBrushUpdate as VoidFun1<ChartEvent>);
    _context?.addEventCall(EventType.brushEnd, onBrushEnd as VoidFun1<ChartEvent>);
    _context?.addEventCall(EventType.brushEnd, onBrushEnd as VoidFun1<ChartEvent>);
  }

  void unsubscribeBrushEvent() {
    _context?.removeEventCall(onBrushUpdate as VoidFun1);
    _context?.removeEventCall(onBrushEnd as VoidFun1);
    _context?.removeEventCall(onBrushStart as VoidFun1);
  }

  void onBrushUpdate(covariant BrushUpdateEvent event) {}

  void onBrushEnd(covariant BrushEndEvent event) {}

  void onBrushStart(covariant BrushStartEvent event) {}

  /// 注册Legend组件事件
  void subscribeLegendEvent() {
    _context?.addEventCall(EventType.legendScroll, onLegendScroll as VoidFun1<ChartEvent>?);
    _context?.addEventCall(EventType.legendInverseSelect, onLegendInverseSelect as VoidFun1<ChartEvent>?);
    _context?.addEventCall(EventType.legendSelectAll, onLegendSelectedAll as VoidFun1<ChartEvent>?);
    _context?.addEventCall(EventType.legendUnSelect, onLegendUnSelected as VoidFun1<ChartEvent>?);
    _context?.addEventCall(EventType.legendSelectChanged, onLegendSelectChange as VoidFun1<ChartEvent>?);
  }

  void onLegendInverseSelect(covariant LegendInverseSelectEvent event) {}

  void onLegendSelectedAll(covariant LegendSelectAllEvent event) {}

  void onLegendUnSelected(covariant LegendUnSelectedEvent event) {}

  void onLegendSelectChange(covariant LegendSelectChangeEvent event) {}

  void onLegendScroll(covariant LegendScrollEvent event) {}

  void unsubscribeLegendEvent() {
    _context?.removeEventCall(onLegendInverseSelect as VoidFun1<ChartEvent>?);
    _context?.removeEventCall(onLegendSelectedAll as VoidFun1<ChartEvent>?);
    _context?.removeEventCall(onLegendUnSelected as VoidFun1<ChartEvent>?);
    _context?.removeEventCall(onLegendSelectChange as VoidFun1<ChartEvent>?);
    _context?.removeEventCall(onLegendScroll as VoidFun1<ChartEvent>?);
  }

  //========Legend 结束================

  ///注册坐标系滚动事件
  VoidFun1<ChartEvent>? _axisScrollListener;

  void subscribeAxisScrollEvent() {
    _context?.removeEventCall2(EventType.axisScroll, _axisScrollListener);
    _axisScrollListener = (event) {
      if (event is AxisScrollEvent) {
        onAxisScroll(event);
        return;
      }
    };
    _context?.addEventCall(EventType.axisScroll, _axisScrollListener);
  }

  void unsubscribeAxisScrollEvent() {
    _context?.removeEventCall2(EventType.axisScroll, _axisScrollListener);
    _axisScrollListener = null;
  }

  void onAxisScroll(AxisScrollEvent event) {}

  VoidFun1<ChartEvent>? _axisChangeListener;

  void subscribeAxisChangeEvent() {
    _context?.removeEventCall(_axisChangeListener);
    _axisChangeListener = (event) {
      if (event is AxisChangeEvent) {
        onAxisChange(event);
        return;
      }
    };
    _context?.addEventCall(EventType.axisChange, _axisChangeListener);
  }

  void unsubscribeAxisChangeEvent() {
    _context?.removeEventCall(_axisChangeListener);
    _axisChangeListener = null;
  }

  void onAxisChange(AxisChangeEvent event) {}
}
