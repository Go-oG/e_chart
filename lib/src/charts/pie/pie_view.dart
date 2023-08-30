import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'pie_helper.dart';
import 'pie_node.dart';

/// 饼图
class PieView extends SeriesView<PieSeries, PieHelper> {
  PieView(super.series);

  @override
  void onDraw(Canvas canvas) {
    List<PieNode> nodeList = layoutHelper.nodeList;
    each(nodeList, (node, i) {
    node.onDraw(canvas, mPaint);
    });
  }

  void drawText(Canvas canvas, PieNode node) {
    node.updateTextPosition(series);
    var labelStyle = node.labelStyle;
    var config = node.textDrawConfig;

    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    if (labelStyle == null || !labelStyle.show || config == null) {
      return;
    }

    if (series.labelAlign == CircleAlign.center) {
      if (layoutHelper.hoverNode == null) {
        return;
      }
      if (node != layoutHelper.hoverNode) {
        return;
      }
      labelStyle.draw(canvas, mPaint, node.data.label!, config);
      return;
    }
    labelStyle.draw(canvas, mPaint, node.data.label!, config);

    if (series.labelAlign == CircleAlign.outside) {
      Offset center = layoutHelper.center;
      Arc arc = node.attr;
      Offset tmpOffset = circlePoint(arc.outRadius, arc.startAngle + (arc.sweepAngle / 2), center);
      Offset tmpOffset2 = circlePoint(
        arc.outRadius + (labelStyle.guideLine?.length ?? 0),
        arc.startAngle + (arc.sweepAngle / 2),
        center,
      );
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(config.offset.dx, config.offset.dy);
      labelStyle.guideLine?.style.drawPath(canvas, mPaint, path);
    }
  }


  @override
  PieHelper buildLayoutHelper() {
    return PieHelper(context, series);
  }

}
