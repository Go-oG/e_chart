import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/layout.dart';
import 'package:flutter/material.dart';

import 'heat_map_node.dart';

/// 热力图
class HeatMapView extends SeriesView<HeatMapSeries> with GridChild, CalendarChild {
  final HeatMapLayout helper = HeatMapLayout();

  HeatMapView(super.series);

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  void onStart() {
    super.onStart();
    helper.addListener(() {
      invalidate();
    });
  }

  @override
  void onStop() {
    helper.clearListener();
    super.onStop();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    ChartTheme chartTheme = context.config.theme;
    HeadMapTheme theme = chartTheme.headMapTheme;
    each(helper.nodeList, (node, index) {
      getAreaStyle(node, index)?.drawRect(canvas, mPaint, node.attr);
      getBorderStyle(node, index)?.drawRect(canvas, mPaint, node.attr);

      if (node.data.label == null || node.data.label!.isEmpty) {
        return;
      }
      var label = node.data.label!;
      LabelStyle? style;
      if (series.labelFun != null) {
        style = series.labelFun?.call(node.d);
      } else {
        style = theme.labelStyle.convert(node.status);
      }
      if (style == null || !style.show) {
        return;
      }
      Alignment align = series.labelAlignFun?.call(node.d) ?? Alignment.center;
      style.draw(canvas, mPaint, label, TextDrawInfo.fromRect(node.attr, align));
    });
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      if (isXAxis) {
        dl.add(element.x);
      } else {
        dl.add(element.y);
      }
    }
    return dl;
  }

  AreaStyle? getAreaStyle(HeatMapNode node, int index) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node.data);
    }
    var chartTheme = context.config.theme;
    Color fillColor = chartTheme.getColor(index);
    return AreaStyle(color: fillColor).convert(node.status);
  }

  LineStyle? getBorderStyle(HeatMapNode node, int index) {
    if (series.borderStyleFun != null) {
      return series.borderStyleFun?.call(node.data);
    }
    var theme = context.config.theme.headMapTheme;
    return theme.getBorderStyle()?.convert(node.status);
  }
}
