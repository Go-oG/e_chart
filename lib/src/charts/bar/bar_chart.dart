import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/bar/helper/grid_helper.dart';
import 'package:e_chart/src/charts/bar/helper/polar_helper.dart';
import 'package:flutter/material.dart';

///BarView
class BarView extends CoordChildView<BarSeries> with GridChild, PolarChild {
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
  ChartLayout<ChartSeries, dynamic>? getLayoutHelper() => helper;

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
    canvas.save();
    canvas.translate(offset.dx, 0);
    var nodeMap = helper.showNodeMap;
    nodeMap.forEach((key, node) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.data, node.parent);
      } else if (group.isHover) {
        style = s2;
      }
      if (style != null) {
        if (series.coordSystem == CoordSystem.polar) {
          style.drawPath(canvas, mPaint, group.arc.toPath(false));
        } else {
          style.drawRect(canvas, mPaint, group.rect);
        }
      }
      rectSet.add(group);
    });

    canvas.restore();
    return;
  }

  void drawBar(Canvas canvas) {
    Offset offset = helper.getTranslation();
    final map = helper.showNodeMap;
    final bool usePolar = series.coordSystem == CoordSystem.polar;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (!usePolar && node.rect.isEmpty) {
        return;
      }
      if (usePolar && node.arc.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = helper.buildAreaStyle(data, group, node.groupIndex, node.status);
      var ls = helper.buildLineStyle(data, group, node.groupIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      if (as == null && ls == null) {
        return;
      }

      if (usePolar) {
        as?.drawPath(canvas, mPaint, node.arc.toPath(true));
        ls?.drawPath(canvas, mPaint, node.arc.toPath(true));
      } else {
        Corner corner = series.corner;
        if (series.cornerFun != null) {
          corner = series.cornerFun!.call(data, group);
        }
        as?.drawRect(canvas, mPaint, node.rect, corner);
        ls?.drawRect(canvas, mPaint, node.rect, corner);
      }
    });

    ///这里分开是为了避免遮挡
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (!usePolar && node.rect.isEmpty) {
        return;
      }
      if (usePolar && node.arc.isEmpty) {
        return;
      }
      drawBarLabel(canvas, node);
    });
    canvas.restore();
  }

  void drawBarLabel(Canvas canvas, SingleNode<BarItemData, BarGroupData> node) {
    var data = node.data!;
    var group = node.parent;
    LabelStyle? style = series.getLabelStyle(context, data, group);
    if (style == null || !style.show) {
      return;
    }
    DynamicText? text = series.formatData(context, data, group);
    if (text == null || text.isEmpty) {
      return;
    }
    ChartAlign align = series.getLabelAlign(context, data, group);
    TextDrawInfo drawInfo = align.convert(node.rect, style, series.direction);
    style.draw(canvas, mPaint, text, drawInfo);
  }

  /// 绘制标记点
  void drawMakePoint(Canvas canvas) {
    ///TODO 待完成
  }

  /// 绘制标记线
  void drawMakeLine(Canvas canvas) {
    ///TODO 待完成
  }

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
  List<DynamicData> getAngleDataSet() {
    return getAxisExtreme(0, false);
  }

  @override
  List<DynamicData> getRadiusDataSet() {
    return getAxisExtreme(0, true);
  }
}
