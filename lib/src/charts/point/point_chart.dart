import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/point/point_layout.dart';
import 'package:flutter/material.dart';

import 'point_node.dart';

class PointView extends SeriesView<PointSeries> with PolarChild, CalendarChild,GridChild {
  final PointLayout _layout = PointLayout();

  PointView(super.series);

  @override
  void onClick(Offset offset) {
    handleHover(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    handleHover(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    handleHover(offset);
  }

  @override
  void onHoverEnd() {
    handleCancel();
  }

  void handleHover(Offset offset) {
    PointNode? clickNode;
    var nodeList = _layout.nodeList;
    for (var node in nodeList) {
      if (series.includeFun != null && series.includeFun!.call(node, offset)) {
        clickNode = node;
        break;
      }
      if (node.rect.contains(offset)) {
        clickNode = node;
        break;
      }
    }
    bool result = false;
    for (var node in nodeList) {
      if (node == clickNode) {
        if (node.addState(ViewState.hover)) {
          result = true;
        }
      } else {
        if (node.removeState(ViewState.hover)) {
          result = true;
        }
      }
    }
    if (result) {
      invalidate();
    }
  }

  void handleCancel() {
    bool result = false;
    for (var node in _layout.nodeList) {
      if (node.removeState(ViewState.hover)) {
        result = true;
      }
    }
    if (result) {
      invalidate();
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, selfBoxBound,LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var node in _layout.nodeList) {
      ChartSymbol symbol = series.symbolStyle.call(node);
      symbol.draw(canvas, mPaint,SymbolDesc(center: node.rect.center));
    }
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List<DynamicData> get angleDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.y);
    }
    return dl;
  }

  @override
  List<DynamicData> get radiusDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.x);
    }
    return dl;
  }

  @override
  int get xAxisIndex => series.xAxisIndex;

  @override
  List<DynamicData> get xDataSet => List.from(series.data.map((e) => e.x));

  @override
  int get xDataSetCount =>series.data.length;

  @override
  int get yAxisIndex => series.yAxisIndex;

  @override
  List<DynamicData> get yDataSet => List.from(series.data.map((e) => e.y));

  @override
  int get yDataSetCount => series.data.length;
}
