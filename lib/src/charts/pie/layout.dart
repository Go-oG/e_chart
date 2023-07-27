import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/src/charts/pie/pie_tween.dart';

import 'package:e_chart/src/utils/diff.dart';
import 'package:flutter/material.dart';

import '../../animation/index.dart';
import '../../core/layout.dart';
import '../../core/view_state.dart';
import '../../ext/offset_ext.dart';

import '../../model/index.dart';
import '../../shape/arc.dart';
import '../../style/label.dart';
import '../../utils/align_util.dart';
import 'pie_series.dart';

///饼图布局
class PieLayout extends ChartLayout<PieSeries, List<ItemData>> {
  List<PieNode> _nodeList = [];

  List<PieNode> get nodeList => _nodeList;

  num maxData = double.minPositive;
  num minData = double.maxFinite;
  num allData = 0;

  num minRadius = 0;
  num maxRadius = 0;

  num pieAngle = 0;
  Offset center = Offset.zero;

  @override
  void onLayout(List<ItemData> data, LayoutType type) {
    pieAngle = _adjustPieAngle(series.sweepAngle);
    center = _computeCenterPoint(series.center);
    hoverNode = null;
    _preHandleRadius();
    List<PieNode> oldList = _nodeList;
    List<PieNode> newList = _preHandleData(data);
    layoutNode(newList);
    DiffResult<PieNode, ItemData> result = DiffUtil.diff(oldList, newList, (p0) => p0.data, (p0, p1, newData) {
      PieAnimatorStyle style = series.animatorStyle;
      PieNode node = PieNode(p0);
      Arc arc = p1.arc;
      if (newData) {
        if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
          arc = arc.copy(outRadius: arc.innerRadius);
        }
        if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
          arc = arc.copy(startAngle: series.offsetAngle);
        }
        arc = arc.copy(sweepAngle: 0);
        node.arc = arc;
      } else {
        node.arc = arc.copy(sweepAngle: 0, outRadius: arc.innerRadius);
      }
      return node;
    });

    PieTween arcTween = PieTween(Arc(), Arc(), props: series.animatorProps);

    ChartDoubleTween tween = ChartDoubleTween(props: series.animatorProps);

    Map<ItemData, Arc> startMap = result.startMap.map((key, value) => MapEntry(key, value.arc));
    Map<ItemData, Arc> endMap = result.endMap.map((key, value) => MapEntry(key, value.arc));

    tween.startListener = () {
      _nodeList = result.curList;
    };
    tween.endListener = () {
      _nodeList = result.finalList;
      notifyLayoutEnd();
    };

    tween.addListener(() {
      double v = tween.value;
      for (var node in result.curList) {
        var s = startMap[node.data]!;
        var e = endMap[node.data]!;
        arcTween.changeValue(s, e);
        node.arc = arcTween.safeGetValue(v);
      }
      notifyLayoutUpdate();
    });
    tween.start(context, type==LayoutType.update);
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

  void layoutUserClickWithHover(Offset offset) {
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

    PieNode? oldHoverNode = hoverNode;
    hoverNode = clickNode;
    oldHoverNode?.removeStates([ViewState.hover, ViewState.focused]);
    clickNode?.addStates([ViewState.hover, ViewState.focused]);

    Map<PieNode, Arc> oldMap = {};
    each(nodeList, (node, p1) {
      oldMap[node] = node.arc;
    });

    layoutNode(nodeList);
    List<PieTween> tweenList = [];
    each(nodeList, (node, p1) {
      if (oldHoverNode != null && node.data == oldHoverNode.data) {
        PieTween tween = PieTween(oldMap[node]!, node.arc, props: series.animatorProps);
        tween.addListener(() {
          oldHoverNode.arc = tween.value;
          notifyLayoutUpdate();
        });
        tweenList.add(tween);
        return;
      }
      if (node == clickNode) {
        Arc p;
        if (series.scaleExtend.percent) {
          var or = node.arc.outRadius * (1 + series.scaleExtend.percentRatio());
          p = node.arc.copy(outRadius: or);
        } else {
          p = node.arc.copy(outRadius: node.arc.outRadius + series.scaleExtend.number);
        }
        PieTween tween = PieTween(oldMap[node]!, p, props: series.animatorProps);
        tween.addListener(() {
          clickNode!.arc = tween.value;
          notifyLayoutUpdate();
        });
        tweenList.add(tween);
      }
    });
    for (var tween in tweenList) {
      tween.start(context, true);
    }
  }

  void onHoverEnd() {
    if (hoverNode == null) {
      return;
    }
    var node = hoverNode!;
    hoverNode = null;
    num or;
    if (series.scaleExtend.percent) {
      or = node.arc.outRadius / (1 + series.scaleExtend.percentRatio());
    } else {
      or = node.arc.outRadius - series.scaleExtend.number;
    }
    PieTween tween = PieTween(node.arc, node.arc.copy(outRadius: or), props: series.animatorProps);
    tween.addListener(() {
      node.arc = tween.value;
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
      nodeList.add(PieNode(data));
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
      node.arc = Arc(
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
        node.arc = Arc(
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
        node.arc = Arc(
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
      if (offset.inArc(ele.arc)) {
        node = ele;
        break;
      }
    }
    return node;
  }
}

class PieNode with ViewStateProvider {
  final ItemData data;
  bool select = false;

  Arc arc = Arc();

  PieNode(this.data);

  ///计算文字的位置
  TextDrawConfig? textDrawConfig;
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
      textDrawConfig = TextDrawConfig(arc.center, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.inside) {
      double radius = (arc.innerRadius + arc.outRadius) / 2;
      double angle = arc.startAngle + arc.sweepAngle / 2;
      Offset offset = circlePoint(radius, angle).translate(arc.center.dx, arc.center.dy);
      textDrawConfig = TextDrawConfig(offset, align: Alignment.center);
      return;
    }
    if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle!.guideLine?.length??0;
      double centerAngle = arc.startAngle + arc.sweepAngle / 2;
      Offset offset = circlePoint(arc.outRadius + expand, centerAngle, arc.center);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        align = Alignment.centerRight;
      } else {
        align = Alignment.centerLeft;
      }
      textDrawConfig = TextDrawConfig(offset, align: align);
      return;
    }
  }
}
