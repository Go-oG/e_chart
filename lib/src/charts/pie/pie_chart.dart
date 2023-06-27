import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'layout.dart';

/// 饼图
class PieView extends SeriesView<PieSeries> {
  final PieLayout pieLayer = PieLayout();

  PieView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    pieLayer.layoutUserClickWithHover(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    pieLayer.layoutUserClickWithHover(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    pieLayer.layoutUserClickWithHover(offset);
  }

  @override
  void onHoverEnd() {
    pieLayer.clearHover();
  }

  @override
  void onUpdateDataCommand(Command c) {
    pieLayer.doLayout(context, series, series.data, width, height, true);
  }

  @override
  void onStart() {
    super.onStart();
    pieLayer.addListener(() {
      invalidate();
    });
  }

  @override
  void onStop() {
    pieLayer.clearListener();
    super.onStop();
  }

  @override
  void onDestroy() {
    pieLayer.dispose();
    super.onDestroy();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    pieLayer.doLayout(context, series, series.data, width, height, false);
  }

  @override
  void onDraw(Canvas canvas) {
    List<PieNode> nodeList = pieLayer.nodeList;
    for (var node in nodeList) {
      AreaStyle style = series.areaStyleFun.call(node.data);
      if (!style.show) {
        continue;
      }
      style.drawPath(canvas, mPaint, node.arc.toPath(true));
    }

    for (var node in nodeList) {
      drawText(canvas, node);
    }
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
      if (pieLayer.hoverNode == null) {
        return;
      }
      if (node != pieLayer.hoverNode) {
        return;
      }
      labelStyle.draw(canvas, mPaint, node.data.label!, config);
      return;
    }
    labelStyle.draw(canvas, mPaint, node.data.label!, config);

    if (series.labelAlign == CircleAlign.outside) {
      Offset center = pieLayer.center;
      Arc arc = node.arc;
      Offset tmpOffset = circlePoint(arc.outRadius, arc.startAngle + (arc.sweepAngle / 2), center);
      Offset tmpOffset2 = circlePoint(
        arc.outRadius + labelStyle.guideLine.length,
        arc.startAngle + (arc.sweepAngle / 2),
        center,
      );
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(config.offset.dx, config.offset.dy);
      labelStyle.guideLine.style.drawPath(canvas, mPaint, path);
    }
  }
}
