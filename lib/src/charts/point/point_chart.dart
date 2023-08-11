import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/point/point_helper.dart';
import 'package:flutter/material.dart';

import 'point_node.dart';

class PointView extends CoordChildView<PointSeries, PointHelper> with PolarChild, CalendarChild, GridChild {
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
    var nodeList = layoutHelper.nodeList;
    for (var node in nodeList) {
      if (series.includeFun != null && series.includeFun!.call(node, offset)) {
        clickNode = node;
        break;
      }
      if (node.internal(offset)) {
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
    for (var node in layoutHelper.nodeList) {
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
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var node in layoutHelper.nodeList) {
      node.symbol?.draw(canvas, mPaint, node.attr);
    }
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List<dynamic> getAngleExtreme() {
    List<dynamic> dl = [];
    for (var ele in series.data) {
      dl.add(ele.y);
    }
    return dl;
  }

  @override
  List<dynamic> getRadiusExtreme() {
    List<dynamic> dl = [];
    for (var ele in series.data) {
      dl.add(ele.x);
    }
    return dl;
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    if (isXAxis) {
      return List.from(series.data.map((e) => e.x));
    } else {
      return List.from(series.data.map((e) => e.y));
    }
  }

  @override
  PointHelper buildLayoutHelper() {
    return PointHelper(context, series);
  }
}
