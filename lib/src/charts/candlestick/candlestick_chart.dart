import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/candlestick/candlestick_layout.dart';
import 'package:flutter/material.dart';

import 'candlestick_node.dart';

/// 单个K线图
class CandleStickView extends CoordChildView<CandleStickSeries> with GridChild {
  final CandlestickLayout _layout = CandlestickLayout();

  CandleStickView(super.series);

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
    _layout.onHoverEnd();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
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
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    GridCoord layout = context.findGridCoord();
    Offset of = layout.getTranslation();
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(_layout.nodeList, (node, index) {
      each(node.nodeList, (p0, p1) {
        drawNode(canvas, p0);
      });

    });
    canvas.restore();
  }

  void drawNode(Canvas canvas, CandlestickNode node) {
    AreaStyle? areaStyle=series.getAreaStyle(context, node.data, node.parent, node.groupIndex!);
    areaStyle?.drawPath(canvas, mPaint, node.areaPath);
    LineStyle? style=series.getBorderStyle(context, node.data, node.parent, node.groupIndex!);
    style?.drawPath(canvas, mPaint, node.path);
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    List<DynamicData> dl = [];
    for(var group in series.data){
      for (var element in group.data) {
        if (isXAxis) {
          dl.add(DynamicData(element.time));
        } else {
          dl.add(DynamicData(element.highest));
          dl.add(DynamicData(element.lowest));
        }
      }
    }

    return dl;
  }

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    // TODO: implement getAxisMaxText
    return DynamicText.empty;
  }
  @override
  void onGridScrollChange(Offset scroll) {

  }
}
