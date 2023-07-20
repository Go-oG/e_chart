import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final FunnelLayout helper = FunnelLayout();

  FunnelView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    helper.hoverEnter(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    helper.hoverEnter(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    helper.hoverEnter(offset);
  }

  @override
  void onHoverEnd() {
    helper.clearHover();
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
      FunnelLayout.getBorderStyle(context, series, node)?.drawPath(canvas, mPaint, node.path);
    }
    for (var node in nodeList) {
      _drawText(canvas, node);
    }
  }

  void _drawText(Canvas canvas, FunnelNode node) {
    TextDrawConfig? config = node.textConfig;
    DynamicText? label = node.data.label;
    if (label == null || label.isEmpty || config == null) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node);
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
