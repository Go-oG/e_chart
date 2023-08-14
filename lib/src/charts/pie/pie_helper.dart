import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pie/pie_tween.dart';

import 'package:flutter/material.dart';

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
    pieAngle = _adjustPieAngle(series.sweepAngle);
    center = _computeCenterPoint(series.center);
    hoverNode = null;
    _preHandleRadius();
    List<PieNode> oldList = _nodeList;
    List<PieNode> newList = _preHandleData(series.data);
    layoutNode(newList);

    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      _nodeList = newList;
      notifyLayoutUpdate();
      return;
    }

    PieTween arcTween = PieTween(Arc(), Arc(), props: animation);
    DiffUtil.diff2<Arc, ItemData, PieNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, add) {
        PieAnimatorStyle style = series.animatorStyle;
        Arc arc = node.attr;
        if (add) {
          if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
            arc = arc.copy(outRadius: arc.innerRadius);
          }
          if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
            arc = arc.copy(startAngle: series.offsetAngle);
          }
          arc = arc.copy(sweepAngle: 0);
        } else {
          arc = arc.copy(sweepAngle: 0, outRadius: arc.innerRadius);
        }
        return arc;
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
  }

  PieNode? hoverNode;

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

  void handleHoverOrClick(Offset offset, bool click) {
    List<PieNode> nodeList = _nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    PieNode? clickNode = findNode(offset);
    bool hasSame = clickNode == hoverNode;
    if (hasSame) {
      return;
    }
    if (clickNode == null && hoverNode == null) {
      return;
    }

    if (click) {
      if (clickNode != null) {
        sendClickEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      }
    } else {
      if (hoverNode != null) {
        sendHoverOutEvent(offset, hoverNode!.data, dataIndex: hoverNode!.dataIndex, groupIndex: hoverNode!.groupIndex);
      }
      if (clickNode != null) {
        sendHoverInEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      }
    }

    var animator = series.animation;
    if (animator == null || animator.updateDuration.inMilliseconds <= 0) {
      hoverNode?.removeStates([ViewState.hover, ViewState.focused]);
      clickNode?.addStates([ViewState.hover, ViewState.focused]);

      return;
    }

    PieNode? oldHoverNode = hoverNode;
    hoverNode = clickNode;
    oldHoverNode?.removeStates([ViewState.hover, ViewState.focused]);
    clickNode?.addStates([ViewState.hover, ViewState.focused]);

    Map<PieNode, Arc> oldMap = {};
    each(nodeList, (node, p1) {
      oldMap[node] = node.attr;
    });

    layoutNode(nodeList);
    List<PieTween> tweenList = [];
    each(nodeList, (node, p1) {
      if (oldHoverNode != null && node.data == oldHoverNode.data) {
        PieTween tween = PieTween(oldMap[node]!, node.attr, props: animator);
        tween.addListener(() {
          oldHoverNode.attr = tween.value;
          notifyLayoutUpdate();
        });
        tweenList.add(tween);
        return;
      }
      if (node == clickNode) {
        Arc p;
        if (series.scaleExtend.percent) {
          var or = node.attr.outRadius * (1 + series.scaleExtend.percentRatio());
          p = node.attr.copy(outRadius: or);
        } else {
          p = node.attr.copy(outRadius: node.attr.outRadius + series.scaleExtend.number);
        }
        PieTween tween = PieTween(oldMap[node]!, p, props: animator);
        tween.addListener(() {
          clickNode!.attr = tween.value;
          notifyLayoutUpdate();
        });
        tweenList.add(tween);
      }
    });
    for (var tween in tweenList) {
      tween.start(context, true);
    }
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

  List<PieNode> _preHandleData(List<ItemData> list) {
    maxData = double.minPositive;
    minData = double.maxFinite;
    allData = 0;

    List<PieNode> nodeList = [];
    each(list, (data, i) {
      nodeList.add(PieNode(data, i, -1));
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

  Offset _computeCenterPoint(List<SNumber> center) {
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    return Offset(x, y);
  }

  num _adjustPieAngle(num angle) {
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

class PieNode extends DataNode<Arc, ItemData> {
  PieNode(ItemData data, int dataIndex, int groupIndex) : super(data, dataIndex, groupIndex, Arc());

  ///计算文字的位置
  TextDrawInfo? textDrawConfig;
  LabelStyle? labelStyle;

  void updateTextPosition(PieSeries series) {
    labelStyle = null;
    textDrawConfig = null;
    var label = data.label;
    if (label == null || label.isEmpty) {
      return;
    }
    labelStyle = series.labelStyleFun?.call(data);
    if (labelStyle == null || !labelStyle!.show) {
      return;
    }
    if (series.labelAlign == CircleAlign.center) {
      textDrawConfig = TextDrawInfo(attr.center, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.inside) {
      double radius = (attr.innerRadius + attr.outRadius) / 2;
      double angle = attr.startAngle + attr.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle).translate(attr.center.dx, attr.center.dy);
      textDrawConfig = TextDrawInfo(offset, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle!.guideLine?.length ?? 0;
      double centerAngle = attr.startAngle + attr.sweepAngle / 2;
      Offset offset = circlePoint(attr.outRadius + expand, centerAngle, attr.center);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        align = Alignment.centerRight;
      } else {
        align = Alignment.centerLeft;
      }
      textDrawConfig = TextDrawInfo(offset, align: align);
      return;
    }
  }
}
