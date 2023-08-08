import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class StackGridBarView<T extends StackItemData, G extends StackGridBarGroupData<T>, S extends StackGridBarSeries<T, G>,
    L extends StackGridHelper<T, G, S>> extends CoordChildView<S, L> with GridChild {
  ///用户优化视图绘制
  StackGridBarView(super.series);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    drawGroupBk(canvas);
    drawBar(canvas);
    drawMakeLineAndMarkPoint(canvas);
  }

  void drawGroupBk(Canvas canvas) {
    Set<GroupNode> rectSet = {};
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, 0);
    var nodeMap = layoutHelper.showNodeMap;
    nodeMap.forEach((key, node) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.data, node.parent, node.status);
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
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (node.rect.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = layoutHelper.buildAreaStyle(data, group, node.groupIndex, node.status);

      var ls = layoutHelper.buildLineStyle(data, group, node.groupIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      if (as == null && ls == null) {
        return;
      }
      Corner corner = series.corner;
      if (series.cornerFun != null) {
        corner = series.cornerFun!.call(data, group, node.status);
      }
      as?.drawRect(canvas, mPaint, node.rect, corner);
      ls?.drawRect(canvas, mPaint, node.rect, corner);
    });

    ///这里分开是为了避免遮挡
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (node.rect.isEmpty) {
        return;
      }
      drawBarLabel(canvas, node);
    });
    canvas.restore();
  }

  void drawBarLabel(Canvas canvas, SingleNode<T, G> node) {
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

  /// 绘制标记线和点
  void drawMakeLineAndMarkPoint(Canvas canvas) {
    var markLineFun = series.markLineFun;
    var markPointFun = series.markPointFun;
    var markPoint = series.markPoint;
    var markLine = series.markLine;
    if (markLineFun == null && markPointFun == null && markPoint == null && markLine == null) {
      return;
    }
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (markLineFun != null || markLine != null) {
      each(layoutHelper.markLineList, (ml, i) {
        ml.line.draw(canvas, mPaint, ml.start.offset, ml.end.offset);
      });
    }
    each(layoutHelper.markPointList, (mp, i) {
      mp.markPoint.draw(canvas, mPaint, mp.offset);
    });
    canvas.restore();
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
    return layoutHelper.getAxisExtreme(series, axisIndex, isXAxis);
  }
}
