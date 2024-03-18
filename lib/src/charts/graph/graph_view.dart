import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class GraphView extends SeriesView<GraphSeries, GraphHelper> {
  GraphView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    var graph = layoutHelper.graph;
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (var edge in graph.edges) {
      edge.onDraw(canvas, mPaint);
    }
    for (var node in layoutHelper.dataSet) {
      node.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  GraphHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearListener();
    oldHelper?.clearRef();
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return GraphHelper(context, this, series);
  }

  @override
  bool get enableDrag => series.enableDrag;
}
