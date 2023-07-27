import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class ChartLayout<S extends ChartSeries, T> extends ChartNotifier<Command> {
  ChartLayout({bool equalsObject = false}) : super(Command.none, equalsObject);

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  late Context context;
  late S series;

  Rect rect = Rect.zero;
  late T data;

  void doMeasure(Context context, S series, T data, double parentWidth, double parentHeight) {
    this.context = context;
    this.series = series;
    this.rect = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
    onMeasure();
  }

  void doLayout(Context context, S series, T data, Rect rect, LayoutType type) {
    this.context = context;
    this.series = series;
    this.rect = rect;
    this.data = data;
    onLayout(data, type);
  }

  void onLayout(T data, LayoutType type);

  void onMeasure() {}

  void stopLayout() {}

  double get width => rect.width;

  double get height => rect.height;

  void onClick(Offset localOffset){}

  void onHoverStart(Offset localOffset){}

  void onHoverMove(Offset localOffset){}

  void handleHoverOrClick(Offset offset, bool click) {

  }

  void onHoverEnd() {

  }

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







}

enum LayoutType { none, layout, update }
