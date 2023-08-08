import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于辅助布局相关的抽象类
///一般情况下SeriesView 都需要一个Helper来辅助布局
abstract class LayoutHelper<S extends ChartSeries, T> extends ChartNotifier<Command> {
  late Context context;
  late S series;
  Rect rect = Rect.zero;
  late T data;

  LayoutHelper(this.context, this.series, {bool equalsObject = false}) : super(Command.none, equalsObject);

  LayoutHelper.lazy({bool equalsObject = false}) : super(Command.none, equalsObject);

  void doMeasure(T data, double parentWidth, double parentHeight) {
    this.rect = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
    onMeasure();
  }

  void doLayout(T data, Rect rect, LayoutType type) {
    this.rect = rect;
    this.data = data;
    onLayout(data, type);
  }

  void onLayout(T data, LayoutType type);

  void onMeasure() {}

  void stopLayout() {}

  double get width => rect.width;

  double get height => rect.height;

  void onClick(Offset localOffset) {}

  void onHoverStart(Offset localOffset) {}

  void onHoverMove(Offset localOffset) {}

  void handleHoverOrClick(Offset offset, bool click) {}

  void onHoverEnd() {}

  ///=======事件通知=======
  ///Brush
  void onBrushEvent(BrushEvent event) {}

  void onBrushEndEvent(BrushEndEvent event) {}

  void onBrushClearEvent(BrushClearEvent event) {}

  ///Legend
  void onLegendSelectedEvent(LegendSelectedEvent event) {}

  void onLegendUnSelectedEvent(LegendUnSelectedEvent event) {}

  void onLegendSelectChangeEvent(LegendSelectChangeEvent event) {}

  void onLegendScrollEvent(LegendScrollEvent event) {}

  ///dataZoom
  void onDataZoom(DataZoomEvent event) {}

  void sendClickEvent(Offset offset, dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(ClickEvent(buildEventParams(offset, data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex)));
  }

  void sendHoverInEvent(Offset offset, dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(HoverInEvent(buildEventParams(offset, data, dataType: dataType, dataIndex: dataIndex, groupIndex: groupIndex)));
  }

  void sendHoverOutEvent(Offset? offset, dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    context.dispatchEvent(HoverOutEvent(buildEventParams(
      offset,
      data,
      dataType: dataType,
      dataIndex: dataIndex,
      groupIndex: groupIndex,
    )));
  }

  EventParams buildEventParams(Offset? offset, dynamic data, {DataType dataType = DataType.nodeData, int? dataIndex, int? groupIndex}) {
    return EventParams(
      offset: offset,
      componentType: ComponentType.series,
      data: data,
      dataIndex: dataIndex,
      dataType: dataType,
      groupIndex: groupIndex,
      seriesType: seriesType,
      seriesIndex: series.seriesIndex,
    );
  }

  ///========其它函数=======================
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

  SeriesType get seriesType;

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}

enum LayoutType { none, layout, update }
