import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/bar/helper/grid_helper.dart';
import 'package:e_chart/src/charts/bar/helper/polar_helper.dart';
import 'package:flutter/material.dart';

import '../helper/base_stack_helper.dart';

///BarView
class BarView extends CoordChildView<BarSeries> with GridChild {
  late BaseStackLayoutHelper<BarItemData, BarGroupData, BarSeries> helper;

  ///用户优化视图绘制
  BarView(super.series) {
    if (series.coordSystem == CoordSystem.polar) {
      helper = BarPolarHelper();
    } else {
      helper = BarGridHelper();
    }
  }

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
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    drawGroupBk(canvas);
    drawBar(canvas);
    drawMakePoint(canvas);
    drawMakeLine(canvas);
  }

  void drawGroupBk(Canvas canvas) {
    Set<GroupNode> rectSet = {};

    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    Offset offset = helper.getTranslation();

    each(helper.nodeList, (group, p1) {
      var node = group.parentNode.parentNode;
      if (rectSet.contains(node)) {
        return;
      }
      if (!shouldDraw(node.rect, offset)) {
        return;
      }

      if (group.data == null) {
        return;
      }
      if (series.groupStyleFun != null) {
        AreaStyle? s = series.groupStyleFun?.call(group.data!, group.parent);
        s?.drawRect(canvas, mPaint, group.rect);
        if (s != null) {
          rectSet.add(node);
        }
      } else if (group.isHover) {
        s2.drawRect(canvas, mPaint, group.rect);
        rectSet.add(node);
      }
    });
  }

  void drawBar(Canvas canvas) {
    if (series.coordSystem != CoordSystem.polar) {
      drawBarForGrid(canvas);
      return;
    }

    Offset offset = helper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, 0);
    each(helper.drawNodeList, (node, i) {
      var as = helper.buildAreaStyle(node.data, node.parent, node.groupIndex, node.status);
      node.areaStyle = as;
      Path path = node.arc.toPath(true);
      as?.drawPath(canvas, mPaint, path);
      var ls = helper.buildLineStyle(node.data, node.parent, node.groupIndex, node.status);
      node.lineStyle = ls;
      ls?.drawPath(canvas, mPaint, path);
      return;
    });
    canvas.restore();
  }

  void drawBarForGrid(Canvas canvas) {
    Offset offset = helper.getTranslation();
    bool vertical = series.direction == Direction.vertical;
    double scroll = vertical ? offset.dx : offset.dy;
    scroll = scroll.abs();
    var list = (helper as BarGridHelper).drawNodeList;
    canvas.save();
    canvas.translate(offset.dx, 0);
    each(list, (node, p1) {
      if (node.data == null || node.rect.width == 0 || node.rect.height == 0) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      Corner corner = series.corner;
      if (series.cornerFun != null) {
        corner = series.cornerFun!.call(data, group);
      }
      var as = helper.buildAreaStyle(data, group, node.groupIndex, node.status);
      node.areaStyle = as;
      as?.drawRect(canvas, mPaint, node.rect, corner);
      var ls = helper.buildLineStyle(data, group, node.groupIndex, node.status);
      node.lineStyle = ls;
      ls?.drawRect(canvas, mPaint, node.rect, corner);
    });
    canvas.restore();
  }

  List<int> computeDrawIndexRange(Offset scroll, BarGroupData group) {
    bool vertical = series.direction == Direction.vertical;
    int index = vertical ? group.xAxisIndex : group.yAxisIndex;
    BaseScale scale = helper.findGridCoord().getScale(index, vertical);
    num interval = scale.tickInterval;
    int startIndex, endIndex;
    if (vertical) {
      startIndex = scroll.dx.abs() ~/ interval - 2;
      startIndex = max([startIndex, 0]).toInt();
      endIndex = (scroll.dx.abs() + width) ~/ interval + 2;
      endIndex = min([endIndex, group.data.length]).toInt();
    } else {
      startIndex = scroll.dy.abs() ~/ interval - 2;
      startIndex = max([startIndex, 0]).toInt();
      endIndex = (scroll.dy.abs() + height) ~/ interval + 2;
      endIndex = min([endIndex, group.data.length]).toInt();
    }
    return [startIndex, endIndex];
  }

  bool shouldDraw(Rect rect, Offset scroll) {
    if (series.coordSystem == CoordSystem.polar) {
      return true;
    }
    if (series.direction == Direction.vertical) {
      if (rect.right + scroll.dx < 0) {
        return false;
      }
      if (rect.left + scroll.dx > width) {
        return false;
      }
    } else {
      if (rect.top - scroll.dy < 0) {
        return false;
      }
      if (rect.bottom - scroll.dy > height) {
        return false;
      }
    }
    return true;
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
}
