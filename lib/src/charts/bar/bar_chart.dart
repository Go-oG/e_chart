import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../grid/single_node.dart';
import 'layout_helper.dart';

///BarView
class BarView extends CoordChildView<BarSeries> implements GridChild {
  final BarLayoutHelper helper = BarLayoutHelper();

  ///用户优化视图绘制
  BarView(super.series);

  @override
  void onHoverStart(Offset offset) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverEnd() {
    helper.clearHover();
  }

  @override
  void onClick(Offset offset) {
    helper.handleHoverOrClick(offset, true);
  }

  @override
  void onStart() {
    super.onStart();
    helper.addListener(invalidate);
  }

  @override
  void onStop() {
    helper.removeListener(invalidate);
    super.onStop();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    helper.doMeasure(context, series, series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    drawGroupBk(canvas);
    drawBar(canvas);
    drawMakePoint(canvas);
    drawMakeLine(canvas);
  }

  void drawGroupBk(Canvas canvas) {
    final list = helper.groupNodeList;
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    each(list, (group, p1) {
      if (series.groupStyleFun != null) {
        AreaStyle? s = series.groupStyleFun?.call(group);
        s?.drawRect(canvas, mPaint, group.rect);
      } else if (group.isHover) {
        s2.drawRect(canvas, mPaint, group.rect);
      }
    });
  }

  void drawBar(Canvas canvas) {
    for (var node in helper.nodeList) {
      Corner corner = series.corner;
      if (series.cornerFun != null) {
        corner = series.cornerFun!.call(node);
      }
      getAreaStyle(node, node.data.groupIndex)?.drawRect(canvas, mPaint, node.rect, corner);
      getBorderStyle(node, node.data.groupIndex)?.drawRect(canvas, mPaint, node.rect, corner);
    }
  }

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
    return helper.getAxisExtreme(series, axisIndex, isXAxis);
  }

  @override
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    return helper.getAxisMaxText(series, axisIndex, isXAxis);
  }

  AreaStyle? getAreaStyle(SingleNode<BarItemData, BarGroupData> node, int index) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node);
    }
    var chartTheme = context.config.theme;
    return AreaStyle(color: chartTheme.getColor(index)).convert(node.status);
  }

  LineStyle? getBorderStyle(SingleNode<BarItemData, BarGroupData> node, int index) {
    if (series.borderStyleFun != null) {
      return series.borderStyleFun?.call(node);
    }
    var theme = context.config.theme.barTheme;
    return theme.getBorderStyle();
  }
}
