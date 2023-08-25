import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于辅助布局相关的抽象类
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

  void onDragStart(Offset offset){}

  void onDragMove(Offset offset, Offset diff){}

  void onDragEnd(){}

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
  void sendClickEvent(Offset offset, dynamic data,
      {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(ClickEvent(
      offset,
      toGlobal(offset),
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    ));
  }

  void sendHoverInEvent(Offset offset, dynamic data,
      {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(HoverInEvent(
      offset,
      toGlobal(offset),
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    ));
  }

  void sendHoverOutEvent(dynamic data,
      {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(HoverOutEvent(
      buildEventParams(data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex),
    ));
  }

  EventParams buildEventParams(dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    return EventParams(
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

enum LayoutType { none, layout, update }
