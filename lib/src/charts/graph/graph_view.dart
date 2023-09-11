import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class GraphView extends SeriesView<GraphSeries, GraphLayout> {
  GraphLayout? _oldLayout;

  GraphView(super.series);

  @override
  void onDraw(Canvas canvas) {
    Offset offset = series.layout.getScroll();
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
      style.drawPath(canvas, mPaint, line.toPath(), drawDash: true);
    }
    for (var node in series.graph.nodes) {
      node.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  GraphLayout buildLayoutHelper() {
    if (_oldLayout != series.layout) {
      var l = _oldLayout;
      l?.clearListener();
    }
    series.layout.context = context;
    series.layout.series = series;
    _oldLayout = series.layout;
    return series.layout;
  }
}
