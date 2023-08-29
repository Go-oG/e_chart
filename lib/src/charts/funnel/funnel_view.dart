import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'funnel_node.dart';
import 'funnel_helper.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries,FunnelHelper> {

  FunnelView(super.series);

  @override
  void onDraw(Canvas canvas) {
    List<FunnelNode> nodeList = layoutHelper.nodeList;
    if (nodeList.isEmpty) {
      return;
    }

    for (var node in nodeList) {
      node.areaStyle?.drawPath(canvas, mPaint, node.path);
      series.getBorderStyle(context, node.data, node.dataIndex)?.drawPath(canvas, mPaint, node.path);
    }
    for (var node in nodeList) {
      _drawText(canvas, node);
    }
  }

  void _drawText(Canvas canvas, FunnelNode node) {
    TextDrawInfo? config = node.textConfig;
    DynamicText? label = node.data.label;
    if (label == null || label.isEmpty || config == null) {
      return;
    }
    LabelStyle? style = series.getLabelStyle(context, node.data);
    if (style == null || !style.show) {
      return;
    }
    List<Offset>? ol = node.labelLine;
    if (ol != null) {
      style.guideLine?.style.drawPolygon(canvas, mPaint, ol);
    }
    style.draw(canvas, mPaint, label, config);
  }

  @override
  FunnelHelper buildLayoutHelper() {
    return FunnelHelper(context, series);
  }
}
