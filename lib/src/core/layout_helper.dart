import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于辅助布局相关的抽象类
///其包含了事件分发和触摸事件处理
///一般情况下和SeriesView 配合使用
abstract class LayoutHelper<S extends ChartSeries> extends ChartNotifier<Command> {
  late Context context;
  late S series;
  Rect boxBound = Rect.zero;
  Rect globalBoxBound = Rect.zero;

  LayoutHelper(this.context, this.series, {bool equalsObject = false}) : super(Command.none, equalsObject);

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

  double get width => boxBound.width;

  double get height => boxBound.height;

  ///=========手势处理================
  void onClick(Offset localOffset) {}

  void onHoverStart(Offset localOffset) {}

  void onHoverMove(Offset localOffset) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  ///=========事件通知========
  ///Brush
  void onBrushEvent(BrushEvent event) {}

  void onBrushEndEvent(BrushEndEvent event) {}

  void onBrushClearEvent(BrushClearEvent event) {}

  ///Legend
  void onLegendSelectedEvent(LegendSelectedEvent event) {}

  void onLegendUnSelectedEvent(LegendUnSelectedEvent event) {}

  void onLegendSelectChangeEvent(LegendSelectChangeEvent event) {}

  void onLegendScrollEvent(LegendScrollEvent event) {}

  void onCoordScrollStart(CoordScroll scroll) {}

  void onCoordScrollUpdate(CoordScroll scroll) {}

  void onCoordScrollEnd(CoordScroll scroll) {}

  void onCoordScaleStart(CoordScale scale) {}

  void onCoordScaleUpdate(CoordScale scale) {}

  void onCoordScaleEnd(CoordScale scale) {}

  void onLayoutByParent(LayoutType type) {}

  ///dataZoom
  void onDataZoom(DataZoomEvent event) {}

  ///==============事件发送============
  ClickEvent? _lastClickEvent;

  void sendClickEvent2(Offset offset, dynamic data,
      {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    var lastEvent = _lastClickEvent;
    ClickEvent? event;
    if (lastEvent != null) {
      var old = lastEvent.event;
      if (old.data == data && old.dataType == dataType && old.dataIndex == dataIndex && old.groupIndex == groupIndex) {
        event = lastEvent;
        event.localOffset = offset;
        event.globalOffset = toGlobal(offset);
      }
    }
    event ??= ClickEvent(
      offset,
      toGlobal(offset),
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    );
    _lastClickEvent = event;
    context.dispatchEvent(event);
  }

  void sendClickEvent(Offset offset, DataNode node) {
    sendClickEvent2(offset, node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
  }

  HoverEvent? _lastHoverEvent;

  void sendHoverEvent2(Offset offset, dynamic data,
      {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    var lastEvent = _lastHoverEvent;
    HoverEvent? event;
    if (lastEvent != null) {
      var old = lastEvent.event;
      if (old.data == data && old.dataType == dataType && old.dataIndex == dataIndex && old.groupIndex == groupIndex) {
        event = lastEvent;
        event.localOffset = offset;
        event.globalOffset = toGlobal(offset);
      }
    }
    event ??= HoverEvent(
      offset,
      toGlobal(offset),
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    );
    _lastHoverEvent = event;
    context.dispatchEvent(event);
  }

  void sendHoverEvent(Offset offset, DataNode node) {
    sendHoverEvent2(offset, node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
  }

  void sendHoverEndEvent2(dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(HoverEndEvent(
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    ));
  }

  void sendHoverEndEvent(DataNode node) {
    sendHoverEndEvent2(node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
  }

  EventInfo buildEventParams(dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    return EventInfo(
      componentType: ComponentType.series,
      data: data,
      dataIndex: dataIndex,
      dataType: dataType,
      groupIndex: groupIndex,
      seriesType: seriesType,
      seriesIndex: series.seriesIndex,
    );
  }

  SeriesType get seriesType;

  ///========查找坐标系函数=======================
  GridCoord findGridCoord() {
    return context.findGridCoord(series.gridIndex);
  }

  GridAxis findGridAxis(int index, bool isXAxis) {
    return findGridCoord().getAxis(index, isXAxis);
  }

  PolarCoord findPolarCoord() {
    return context.findPolarCoord(series.polarIndex);
  }

  CalendarCoord findCalendarCoord() {
    return context.findCalendarCoord(series.calendarIndex);
  }

  ParallelCoord findParallelCoord() {
    return context.findParallelCoord(series.parallelIndex);
  }

  RadarCoord findRadarCoord() {
    return context.findRadarCoord(series.radarIndex);
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
}

abstract class LayoutHelper2<N extends DataNode, S extends ChartSeries> extends LayoutHelper<S> {
  List<N> nodeList = [];

  LayoutHelper2(super.context, super.series);

  LayoutHelper2.lazy() : super.lazy();

  double dragX = 0;
  double dragY = 0;

  @override
  void onDragMove(Offset offset, Offset diff) {
    dragX += diff.dx;
    dragY += diff.dy;
    notifyLayoutUpdate();
  }

  @override
  void onClick(Offset localOffset) {
    onHandleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    var old = oldHoverNode;
    oldHoverNode = null;
    if (old == null) {
      return;
    }
    sendHoverEndEvent(old);
    var animation = series.animation;
    var oldAttr = old.toAttr();
    old.removeState(ViewState.hover);
    onUpdateNodeStyle(old);
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      notifyLayoutUpdate();
      return;
    }
    onRunUpdateAnimation(old, oldAttr, null, null, animation);
  }

  N? oldHoverNode;

  void onHandleHoverAndClick(Offset offset, bool click) {
    var oldOffset = offset;
    Offset scroll = getScroll();
    offset = offset.translate2(scroll.invert);
    var clickNode = findNode(offset);
    if (oldHoverNode == clickNode) {
      if (clickNode != null) {
        click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
      }
      return;
    }
    var oldNode = oldHoverNode;
    oldHoverNode = clickNode;
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
    }
    if (clickNode != null) {
      click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
    }

    if (oldNode != null) {
      oldNode.removeState(ViewState.hover);
      onUpdateNodeStyle(oldNode);
    }
    if (clickNode != null) {
      clickNode.addState(ViewState.hover);
      onUpdateNodeStyle(clickNode);
    }

    var animator = series.animation;
    if (animator == null || animator.updateDuration.inMilliseconds <= 0) {
      onHandleHoverAndClickEnd(oldNode, clickNode);
      notifyLayoutUpdate();
      return;
    }
    onRunUpdateAnimation(oldNode, oldNode?.toAttr(), clickNode, clickNode?.toAttr(), animator);
    onHandleHoverAndClickEnd(oldNode, clickNode);
  }

  void onHandleHoverAndClickEnd(N? oldNode, N? newNode) {}

  void onUpdateNodeStyle(N node) {
    node.updateStyle(context, series);
  }

  void onRunUpdateAnimation(N? oldNode, NodeAttr? oldAttr, N? newNode, NodeAttr? newAttr, AnimationAttrs animation);

  N? findNode(Offset offset) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    for (var node in nodeList) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  Offset getScroll() {
    var type = series.coordType;
    if (type == CoordType.polar) {
      return findParallelCoord().getScroll();
    }
    if (type == CoordType.calendar) {
      return findCalendarCoord().getScroll();
    }
    if (type == CoordType.radar) {
      return findRadarCoord().getScroll();
    }
    if (type == CoordType.parallel) {
      return findParallelCoord().getScroll();
    }
    if (type == CoordType.grid) {
      return findGridCoord().getScroll();
    }
    return Offset.zero;
  }
}

enum LayoutType { none, layout, update }
