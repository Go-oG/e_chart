import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/layout.dart';
import 'package:flutter/material.dart';

/// 热力图
class HeatMapView extends SeriesView<HeatMapSeries> implements GridChild, CalendarChild {
  final HeatMapLayout _layout = HeatMapLayout();

  HeatMapView(super.series);

  @override
  int get xAxisIndex => series.xAxisIndex;

  @override
  int get yAxisIndex => series.yAxisIndex;

  @override
  int get xDataSetCount => series.data.length;

  @override
  int get yDataSetCount => series.data.length;

  @override
  List<DynamicData> get xDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.x);
    }
    return dl;
  }

  @override
  List<DynamicData> get yDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.y);
    }
    return dl;
  }

  @override
  int get calendarIndex => series.xAxisIndex;

  @override
  void onStart() {
    super.onStart();
    _layout.addListener(() {
      invalidate();
    });
  }

  @override
  void onStop() {
    _layout.clearListener();
    super.onStop();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.update);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var node in _layout.nodeList) {
      ChartSymbol symbol = series.symbolFun.call(node, node.rect.size).convert(node.status);
      symbol.draw(canvas, mPaint, node.rect.center, 1);
      if (node.data.label != null) {
        LabelStyle? labelStyle = series.labelFun?.call(node);
        if (labelStyle == null || !labelStyle.show) {
          continue;
        }
        Alignment align = series.labelAlignFun?.call(node) ?? Alignment.center;
        labelStyle.draw(canvas, mPaint, node.data.label!, TextDrawConfig.fromRect(node.rect, align));
      }
    }
  }
}
