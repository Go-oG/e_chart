import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///饼图布局
class PieHelper extends LayoutHelper2<PieData, PieSeries> {
  PieHelper(super.context, super.view, super.series);

  num maxData = double.minPositive;
  num minData = double.maxFinite;
  num allData = 0;

  num minRadius = 0;
  num maxRadius = 0;

  num pieAngle = 0;
  int dir = 1;
  Offset center = Offset.zero;

  @override
  void onLayout(LayoutType type) {
    var oldList = nodeList;
    var newList = [...series.data];
    oldHoverNode = null;
    initData(newList);
    var an = DiffUtil.diff<PieData>(
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (dataList) => layoutData(dataList),
      (node, type) {
        var style = series.animatorStyle;
        if (type == DiffType.remove || type == DiffType.update) {
          return {'arc': node.attr};
        }
        Arc arc = node.attr;
        if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
          arc = arc.copy(outRadius: arc.innerRadius);
        }
        if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
          arc = arc.copy(startAngle: series.offsetAngle);
        }
        return {'arc': arc.copy(sweepAngle: 0)};
      },
      (data, type) {
        if (type == DiffType.add || type == DiffType.update) {
          return {'arc': data.attr};
        }
        return {'arc': data.attr.copy(sweepAngle: 0)};
      },
      (data, s, e, t, type) => data.attr = Arc.lerp(s['arc']!, e['arc']!, t),
      (p0, t) {
        nodeList = p0;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  @override
  void initData(List<PieData> dataList) {
    num maxSize = min([width, height]);
    minRadius = series.innerRadius.convert(maxSize);
    maxRadius = series.outerRadius.convert(maxSize);
    if (maxRadius < minRadius) {
      num a = minRadius;
      minRadius = maxRadius;
      maxRadius = a;
    }
    maxData = double.minPositive;
    minData = double.maxFinite;
    allData = 0;
    each(dataList, (data, i) {
      data.dataIndex = i;
      data.updateStyle(context, series);
      maxData = max([data.value, maxData]);
      minData = min([data.value, minData]);
      allData += data.value;
    });
    if (allData == 0) {
      allData = 1;
    }
  }

  void layoutData(List<PieData> nodeList) {
    pieAngle = series.sweepAngle.abs();
    if (pieAngle > 360) {
      pieAngle = 360;
    }
    dir = series.sweepAngle >= 0 ? 1 : -1;
    center = computeCenterPoint(series.center);

    if (nodeList.isEmpty) {
      return;
    }
    if (series.roseType == RoseType.normal) {
      _layoutForNormal(nodeList);
    } else {
      _layoutForNightingale(nodeList);
    }
    for (var node in nodeList) {
      node.extSet("originR", node.attr.outRadius);
      node.updateTextPosition(series);
    }
  }

  //普通饼图
  void _layoutForNormal(List<PieData> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * series.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle <= 0) {
      remainAngle = 1;
    }
    num startAngle = series.offsetAngle;
    num angleGap = series.angleGap * dir;
    each(nodeList, (node, i) {
      var pieData = node;
      num sw = dir * remainAngle * pieData.value / allData;
      Offset c = center;
      double off = series.getOffset(context, pieData);
      if (off.abs() > 1e-6) {
        c = circlePoint(off, startAngle + sw / 2, c);
      }
      node.attr = Arc(
        center: c,
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
  void _layoutForNightingale(List<PieData> nodeList) {
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
    double angleGap = series.angleGap.abs() * dir;
    if (series.roseType == RoseType.area) {
      // 所有扇区圆心角相同，通过半径展示数据大小
      double itemAngle = dir * remainAngle / count;
      num radiusDiff = maxRadius - minRadius;
      each(nodeList, (node, i) {
        var pieData = node;
        Offset c = center;
        double off = series.getOffset(context, pieData);
        if (off.abs() > 1e-6) {
          c = circlePoint(off, startAngle + itemAngle / 2, c);
        }
        node.attr = Arc(
          center: c,
          innerRadius: minRadius,
          outRadius: minRadius + radiusDiff * pieData.value / maxData,
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
        var pieData = node;
        num or = minRadius + (maxRadius - minRadius) * pieData.value / maxData;
        double sweepAngle = dir * remainAngle * pieData.value / allData;
        Offset c = center;
        double off = series.getOffset(context, pieData);
        if (off.abs() > 1e-6) {
          c = circlePoint(off, startAngle + sweepAngle / 2, c);
        }
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
    if (angle.abs() > 360) {
      return 360;
    }
    return angle.abs();
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    List<PieData> oldList = [];
    List<PieData> newList = [];
    for (var diff in list) {
      if (diff.old) {
        oldList.add(diff.node);
      } else {
        newList.add(diff.node);
      }
    }
    const double rDiff = 8;
    DiffUtil.diffUpdate<Arc, PieData>(
      animation,
      oldList,
      newList,
      (node, isOld) {
        num? originR = node.extGetNull("originR");
        if (originR == null) {
          originR = node.attr.outRadius;
          node.extSet("originR", originR);
        }
        if (isOld) {
          return node.attr.copy(outRadius: originR);
        }
        return node.attr.copy(outRadius: originR + rDiff);
      },
      (s, e, t) => Arc.lerp(s, e, t),
      notifyLayoutUpdate,
    ).first.start(context);
  }
}
