import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/graph/graph_view.dart';
class GraphSeries extends RectSeries {
  Graph graph;
  GraphLayout layout;
  Fun3<GraphNode, Size, ChartSymbol> symbolFun;
  Fun3<GraphNode, GraphNode, LineStyle>? lineFun;

  GraphSeries(
    this.graph,
    this.layout, {
    required this.symbolFun,
    this.lineFun,
    super.animation,
    super.backgroundColor,
    super.bottomMargin,
    super.calendarIndex,
    super.clip,
    super.height,
    super.id,
    super.leftMargin,
    super.gridIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.rightMargin,
    super.tooltip,
    super.topMargin,
    super.width,
    super.z,
  });

  @override
  void dispose() {
    layout.dispose();
    super.dispose();
  }
  @override
  ChartView? toView() {
    return GraphView(this);
  }

}
