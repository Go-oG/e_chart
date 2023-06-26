import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries> {
  final FunnelLayout _layout = FunnelLayout();

  FunnelView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _layout.hoverEnter(offset);
  }

  @override
  void onHoverEnd() {
    _layout.clearHover();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    _layout.doLayout(context, series, series.dataList, width, height, true);
  }

  @override
  void onStart() {
    super.onStart();
    _layout.addListener(invalidate);
  }

  @override
  void onStop() {
    _layout.clearListener();
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.dataList, width, height, false);
  }

  @override
  void onDraw(Canvas canvas) {
    List<FunnelNode> nodeList = _layout.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      node.areaStyle.drawPath(canvas, mPaint, node.path);
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
      style.guideLine.style.drawPolygon(canvas, mPaint, ol);
    }
    style.draw(canvas, mPaint, label, config);
  }
}
