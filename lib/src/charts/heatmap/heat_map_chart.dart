import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/layout.dart';
import 'package:flutter/material.dart';

/// 热力图
class HeatMapView extends SeriesView<HeatMapSeries> implements GridChild, CalendarChild {
  final HeatMapLayout _layout = HeatMapLayout();

  HeatMapView(super.series);

  @override
  List<DynamicData> get gridXExtreme {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.x);
    }
    return dl;
  }

  @override
  List<DynamicData> get gridYExtreme {
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
    ChartTheme chartTheme = context.config.theme;
    HeadMapTheme theme = chartTheme.mapTheme;
    for (var node in _layout.nodeList) {
      ChartSymbol? symbol = series.symbolFun?.call(node, node.rect.size);
      if (symbol != null) {
        symbol.draw(canvas, mPaint, SymbolDesc(center: node.rect.center));
      } else if (series.symbolFun == null) {
        symbol = RectSymbol(theme.areaStyle).convert(node.status);
      }

      if (node.data.label == null || node.data.label!.isEmpty) {
        continue;
      }
      var label = node.data.label!;

      LabelStyle? labelStyle = series.labelFun?.call(node);
      if (labelStyle == null && series.labelFun == null) {
        labelStyle = theme.labelStyle.convert(node.status);
      }
      if (labelStyle == null || !labelStyle.show) {
        continue;
      }
      Alignment align = series.labelAlignFun?.call(node) ?? Alignment.center;
      labelStyle.draw(canvas, mPaint, label, TextDrawConfig.fromRect(node.rect, align));
    }
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

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    // TODO: implement getAxisMaxText
    return DynamicText.empty;
  }
}
