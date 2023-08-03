import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'funnel_node.dart';
import 'layout.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final FunnelLayout helper = FunnelLayout();

  FunnelView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    helper.handleHoverOrClick(offset,true);
  }

  @override
  void onHoverStart(Offset offset) {
    helper.handleHoverOrClick(offset,false);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    helper.handleHoverOrClick(offset,false);
  }

  @override
  void onHoverEnd() {
    helper.onHoverEnd();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    helper.doLayout(context, series, series.dataList, selfBoxBound, LayoutType.update);
  }

  @override
  void onStart() {
    super.onStart();
    helper.addListener(invalidate);
  }

  @override
  void onStop() {
    helper.clearListener();
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    helper.doLayout(context, series, series.dataList, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    List<FunnelNode> nodeList = helper.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      node.areaStyle.drawPath(canvas, mPaint, node.path);
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
}
