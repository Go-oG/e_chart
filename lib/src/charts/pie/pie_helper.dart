import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'pie_node.dart';

///饼图布局
class PieHelper extends LayoutHelper2<PieNode, PieSeries> {
  PieHelper(super.context, super.series);

  num maxData = double.minPositive;
  num minData = double.maxFinite;
  num allData = 0;

  num minRadius = 0;
  num maxRadius = 0;

  num pieAngle = 0;
  Offset center = Offset.zero;

  @override
  void onLayout(LayoutType type) {
    pieAngle = adjustPieAngle(series.sweepAngle);
    center = computeCenterPoint(series.center);
    oldHoverNode = null;
    _preHandleRadius();
    List<PieNode> oldList = nodeList;
    List<PieNode> newList = convertData(series.data);
    layoutNode(newList);

    var animation = series.animation;
    if (animation == null || LayoutType.none == type) {
      nodeList = newList;
      return;
    }

    var an = DiffUtil.diffLayout<Arc, ItemData, PieNode>(
      animation,
      oldList,
      newList,
      (data, node, add) {
        PieAnimatorStyle style = series.animatorStyle;
        Arc arc = node.attr;
        if (!add) {
          return arc.copy(sweepAngle: 0, outRadius: arc.innerRadius);
        }
        if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
          arc = arc.copy(outRadius: arc.innerRadius);
        }
        if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
          arc = arc.copy(startAngle: series.offsetAngle);
        }
        return arc.copy(sweepAngle: 0);
      },
      (s, e, t) => Arc.lerp(s, e, t),
      (p0) {
        nodeList = p0;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
  }

  void layoutNode(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    if (series.roseType == RoseType.normal) {
      _layoutForNormal(nodeList);
    } else {
      _layoutForNightingale(nodeList);
    }
    for (var node in nodeList) {
      node.updateTextPosition(series);
    }
  }

  void _preHandleRadius() {
    num maxSize = min([width, height]);
    minRadius = series.innerRadius.convert(maxSize);
    maxRadius = series.outerRadius.convert(maxSize);
    if (maxRadius < minRadius) {
      num a = maxRadius;
      maxRadius = minRadius;
      minRadius = a;
    }
  }

  List<PieNode> convertData(List<ItemData> list) {
    maxData = double.minPositive;
    minData = double.maxFinite;
    allData = 0;

    List<PieNode> nodeList = [];
    Set<ViewState> es = {};
    each(list, (data, i) {
      var as = series.getAreaStyle(context, data, i, es) ?? AreaStyle.empty;
      var bs = series.getBorderStyle(context, data, i, es) ?? LineStyle.empty;
      var ls = series.getLabelStyle(context, data, i, es) ?? LabelStyle.empty;
      nodeList.add(PieNode(data, i, -1, Arc(), as, bs, ls));
      maxData = max([data.value, maxData]);
      minData = min([data.value, minData]);
      allData += data.value;
    });
    if (allData == 0) {
      allData = 1;
    }
    return nodeList;
  }

  //普通饼图
  void _layoutForNormal(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle < 0) {
      remainAngle = 1;
    }

    num startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    remainAngle *= direction;
    num angleGap = series.angleGap * direction;

    each(nodeList, (node, i) {
      var pieData = node.data;
      num sw = remainAngle * pieData.value / allData;
      node.attr = Arc(
        center: center,
        innerRadius: minRadius,
        outRadius: maxRadius,
        startAngle: startAngle,
        sweepAngle: sw,
        cornerRadius: series.corner,
        padAngle: series.angleGap,
      );
      startAngle += sw + angleGap;
    });
  }

  // 南丁格尔玫瑰图
  void _layoutForNightingale(List<PieNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle < 0) {
      remainAngle = 1;
    }
    double startAngle = series.offsetAngle;
    int direction = series.clockWise ? 1 : -1;
    double angleGap = series.angleGap.abs() * direction;
    if (series.roseType == RoseType.area) {
      // 所有扇区圆心角相同，通过半径展示数据大小
      double itemAngle = direction * remainAngle / count;
      each(nodeList, (node, i) {
        var pieData = node.data;
        double percent = pieData.value / maxData;
        node.attr = Arc(
          center: center,
          innerRadius: minRadius,
          outRadius: maxRadius * percent,
          cornerRadius: series.corner,
          startAngle: startAngle,
          sweepAngle: itemAngle,
          padAngle: series.angleGap,
        );
        startAngle += itemAngle + angleGap;
      });
    } else {
      //扇区圆心角展示数据百分比，半径表示数据大小
      each(nodeList, (node, i) {
        ItemData pieData = node.data;
        num or = maxRadius * pieData.value / maxData;
        double sweepAngle = direction * remainAngle * pieData.value / allData;
        node.attr = Arc(
          center: center,
          innerRadius: minRadius,
          cornerRadius: series.corner,
          outRadius: or,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          padAngle: series.angleGap,
        );
        startAngle += sweepAngle + angleGap;
      });
    }
  }

  Offset computeCenterPoint(List<SNumber> center) {
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    return Offset(x, y);
  }

  num adjustPieAngle(num angle) {
    if (angle <= 0) {
      return 1;
    }
    if (angle > 360) {
      return 360;
    }
    return angle.abs();
  }

  @override
  SeriesType get seriesType => SeriesType.pie;

  @override
  void onRunUpdateAnimation(var oldNode, var oldAttr, var newNode, var newAttr, var animation) {
    List<PieNode> oldList = [];
    if (oldNode != null) {
      oldList.add(oldNode);
    }
    List<PieNode> newList = [];
    if (newNode != null) {
      newList.add(newNode);
    }
    const double rDiff = 8;

    DiffUtil.diffUpdate<Arc, ItemData, PieNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, isOld) {
        num? originR = node.extGetNull("originR");
        if (originR == null) {
          originR = node.attr.outRadius;
          node.extSet("originR", originR);
        }
        if (node == oldNode) {
          return node.attr.copy(outRadius: originR - rDiff);
        }
        return node.attr.copy(outRadius: originR + rDiff);
      },
      (s, e, t) => Arc.lerp(s, e, t),
      notifyLayoutUpdate,
    );
  }
}
