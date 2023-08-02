import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
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
    pieLayer.onHoverEnd();
  }

  @override
  void onUpdateDataCommand(Command c) {
    pieLayer.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
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
    pieLayer.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    List<PieNode> nodeList = pieLayer.nodeList;
    each(nodeList, (node, i) {
      Path path=node.attr.toPath(true);
      getAreaStyle(node, i)?.drawPath(canvas, mPaint, path);
      getBorderStyle(node, i)?.drawPath(canvas, mPaint, path);
    });
    each(nodeList, (node, i) {
      drawText(canvas, node);
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

  AreaStyle? getAreaStyle(PieNode node, int index) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node.data);
    }
    var chartTheme = context.config.theme;
    Color fillColor = chartTheme.getColor(index);
    return AreaStyle(color: fillColor);
  }

  LineStyle? getBorderStyle(PieNode node, int index) {
    if (series.borderFun != null) {
      return series.borderFun?.call(node.data);
    }
    var theme = context.config.theme.pieTheme;
    return theme.getBorderStyle();
  }
}
