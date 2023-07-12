import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'layout_helper.dart';

class LineView extends CoordChildView<LineSeries> implements GridChild {
  final LineLayoutHelper layoutHelper = LineLayoutHelper();

  ///用户优化视图绘制
  LineView(super.series);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var line in layoutHelper.lineList) {
      LineStyle style = LineStyle(color: randomColor(), width: 1);
      style.drawPath(canvas, mPaint, line.toPath(false));
    }
  }

  /// 绘制柱状图
  void drawBarElement(Canvas canvas) {}

  /// 绘制标记点
  void drawMakePoint(Canvas canvas) {}

  /// 绘制标记线
  void drawMakeLine(Canvas canvas) {}

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    int count = 0;
    for (var data in series.data) {
      if (data.data.length > count) {
        count = data.data.length;
      }
    }
    return count;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisExtreme(series, axisIndex, isXAxis);
  }

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisMaxText(series, axisIndex, isXAxis);
  }
}
