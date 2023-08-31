import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pie/pie_tween.dart';

import 'package:flutter/material.dart';

import 'pie_node.dart';

///饼图布局
class PieHelper extends LayoutHelper<PieSeries> {
  List<PieNode> _nodeList = [];

  PieHelper(super.context, super.series);

  List<PieNode> get nodeList => _nodeList;

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
    hoverNode = null;

    _preHandleRadius();

    List<PieNode> oldList = _nodeList;
    List<PieNode> newList = convertData(series.data);
    layoutNode(newList);

    var animation = series.animation;
    if (animation == null || LayoutType.none == type) {
      _nodeList = newList;
      return;
    }

    PieTween arcTween = PieTween(Arc(), Arc(), props: animation);
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
      (s, e, t) {
        arcTween.changeValue(s, e);
        return arcTween.safeGetValue(t);
      },
      (p0) {
        _nodeList = p0;
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

  @override
  void onClick(Offset localOffset) {
    handleHoverOrClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHoverOrClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHoverOrClick(localOffset, false);
  }

  PieNode? hoverNode;

  void handleHoverOrClick(Offset offset, bool click) {
    List<PieNode> nodeList = _nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    PieNode? clickNode = findNode(offset);
    if (clickNode == hoverNode) {
      if (clickNode != null) {
        click ? sendClickEvent(offset, clickNode) : sendHoverEvent(offset, clickNode);
      }
      return;
    }

    var oldNode = hoverNode;
    hoverNode = clickNode;

    oldNode?.removeStates([ViewState.hover, ViewState.focused]);
    clickNode?.addStates([ViewState.hover, ViewState.focused]);

    if (oldNode != null) {
      sendHoverEndEvent2(oldNode.data, dataIndex: oldNode.dataIndex, groupIndex: oldNode.groupIndex);
    }
    if (clickNode != null) {
      click ? sendClickEvent(offset, clickNode) : sendHoverEvent(offset, clickNode);
    }

    var animator = series.animation;
    if (animator == null || animator.updateDuration.inMilliseconds <= 0) {
      hoverNode?.removeStates([ViewState.hover, ViewState.focused]);
      clickNode?.addStates([ViewState.hover, ViewState.focused]);
      return;
    }
    List<PieNode> oldList = [];
    if (oldNode != null) {
      oldList.add(oldNode);
    }
    List<PieNode> newList = [];
    if (clickNode != null) {
      newList.add(clickNode);
    }
    const double rDiff = 8;
    PieTween tween = PieTween(Arc(), Arc(), props: animator);
    DiffUtil.diffUpdate<Arc, ItemData, PieNode>(
      context,
      animator,
      oldList,
      newList,
      (data, node, isOld) {
        if (isOld) {
          return node.attr.copy(outRadius: node.attr.outRadius - rDiff);
        }
        return node.attr.copy(outRadius: node.attr.outRadius + rDiff);
      },
      (s, e, t) {
        tween.changeValue(s, e);
        return tween.safeGetValue(t);
      },
      () {
        notifyLayoutUpdate();
      },
    );
  }

  @override
  void onHoverEnd() {
    var node = hoverNode;
    if (node == null) {
      return;
    }
    hoverNode = null;
    num or;
    if (series.scaleExtend.percent) {
      or = node.attr.outRadius / (1 + series.scaleExtend.percentRatio());
    } else {
      or = node.attr.outRadius - series.scaleExtend.number;
    }

    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      node.attr = node.attr.copy(outRadius: or);
      notifyLayoutUpdate();
      return;
    }

    PieTween tween = PieTween(node.attr, node.attr.copy(outRadius: or), props: animation);
    tween.addListener(() {
      node.attr = tween.value;
      notifyLayoutUpdate();
    });
    tween.start(context, true);
    return;
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

  PieNode? findNode(Offset offset) {
    PieNode? node;
    for (var ele in nodeList) {
      if (offset.inArc(ele.attr)) {
        node = ele;
        break;
      }
    }
    return node;
  }

  @override
  SeriesType get seriesType => SeriesType.pie;
}
