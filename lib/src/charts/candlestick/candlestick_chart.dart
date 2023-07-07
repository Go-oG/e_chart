import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/candlestick/candlestick_layout.dart';
import 'package:flutter/material.dart';

import 'candlestick_node.dart';

/// 单个K线图
class CandleStickView extends CoordChildView<CandleStickSeries> implements GridChild {
  final CandlestickLayout _layout = CandlestickLayout();

  CandleStickView(super.series);

  @override
  int get gridX => series.xAxisIndex;

  @override
  int get gridY => series.yAxisIndex;

  @override
  int get gridXDataCount => series.data.length;

  @override
  int get gridYDataCount => gridXDataCount;

  @override
  List<DynamicData> get gridXExtreme {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(DynamicData(element.time));
    }
    return dl;
  }

  @override
  List<DynamicData> get gridYExtreme {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(DynamicData(element.highest));
      dl.add(DynamicData(element.lowest));
    }
    return dl;
  }

  @override
  void onClick(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverEnd() {
    _layout.clearHover();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.update);
  }

  @override
  void onStart() {
    super.onStart();
    _layout.addListener(invalidate);
  }

  @override
  void onStop() {
    _layout.clearListener();
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    GridCoord layout = context.findGridCoord();
    Offset of = layout.getTranslation(series.xAxisIndex, series.yAxisIndex);
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(_layout.nodeList, (node, index) {
      drawNode(canvas, node);
    });
    canvas.restore();
  }

  void drawNode(Canvas canvas, CandlestickNode node) {
    var theme = context.config.theme.kLineTheme;
    AreaStyle? areaStyle;
    var data = node.data;
    if (series.styleFun != null) {
      areaStyle = series.styleFun?.call(node.data);
    } else {
      if (theme.fill) {
        Color color = data.isUp ? theme.upColor : theme.downColor;
        areaStyle = AreaStyle(color: color).convert(node.status);
      }
    }
    areaStyle?.drawPath(canvas, mPaint, node.areaPath);

    LineStyle? style;
    if (series.lineStyleFun != null) {
      style = series.lineStyleFun?.call(node.data);
    } else {
      Color color = data.isUp ? theme.upBorderColor : theme.downBorderColor;
      style = LineStyle(color: color, width: theme.borderWidth).convert(node.status);
    }
    style?.drawPath(canvas, mPaint, node.path, false);
  }
}
