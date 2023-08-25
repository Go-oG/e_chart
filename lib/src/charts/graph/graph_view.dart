import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class GraphView extends SeriesView<GraphSeries, GraphLayout> {
  GraphView(super.series);

  @override
  void onDraw(Canvas canvas) {
    Offset offset = series.layout.getTranslationOffset(width, height);
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (var edge in series.graph.edges) {
      var source = edge.source;
      var target = edge.target;
      LineStyle? style = series.lineFun?.call(source, target);
      if (style == null) {
        continue;
      }
      Line line;
      if (edge.points.length <= 2) {
        line = Line([Offset(source.x, source.y), Offset(target.x, target.y)]);
      } else {
        line = Line(edge.points);
      }
      style.drawPath(canvas, mPaint, line.toPath(false), drawDash: true);
    }
    for (var node in series.graph.nodes) {
      Offset offset = Offset(node.x, node.y);
      ChartSymbol symbol = series.symbolFun.call(node, series.layout.getNodeSize(node));
      symbol.draw(canvas, mPaint, offset);
    }
    canvas.restore();
  }

  @override
  GraphLayout buildLayoutHelper() {
    series.layout.context = context;
    series.layout.series = series;
    return series.layout;
  }
}
