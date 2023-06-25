//漏斗图布局计算相关
import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';

import '../../core/context.dart';
import '../../core/layout.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../../model/enums/sort.dart';
import '../../model/group_data.dart';
import 'funnel_node.dart';
import 'funnel_series.dart';

class FunnelLayout extends ChartLayout {
  FunnelLayout() : super();
  List<FunnelNode> nodeList = [];

  late Context context;
  late FunnelSeries series;
  double width = 0;
  double height = 0;

  num maxValue = 0;

  void doLayout(Context context, FunnelSeries series, List<ItemData> list, double width, double height) {
    this.context = context;
    this.series = series;
    this.width = width;
    this.height = height;
    maxValue = 0;
    if (list.isEmpty) {
      this.nodeList = [];
      return;
    }

    ///直接降序处理
    list.sort((a, b) {
      return a.value.compareTo(b.value);
    });
    maxValue = list.first.value;

    List<FunnelNode> nodeList = [];
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      ItemData? preData = i == 0 ? null : list[i - 1];
      nodeList.add(FunnelNode(preData, data));
      maxValue = max([data.value, maxValue]);
    }

    if (series.maxValue != null && maxValue < series.maxValue!) {
      maxValue = series.maxValue!;
    }
    int count = nodeList.length;
    double gapAllHeight = (count - 1) * series.gap;
    double size = series.direction == Direction.vertical ? height : width;
    double itemSize = (size - gapAllHeight) / count;
    if (series.itemHeight != null) {
      itemSize = series.itemHeight!.convert(height);
    }
    if (series.direction == Direction.vertical) {
      _layoutVertical(nodeList, itemSize);
    } else {
      _layoutHorizontal(nodeList, itemSize);
    }
    for (var node in nodeList) {
      node.update(series);
    }
    this.nodeList = nodeList;
  }

  void _layoutVertical(List<FunnelNode> nodeList, double itemHeight) {
    double offsetY = 0;
    Map<FunnelNode, FunnelProps> propsMap = {};
    double kw = width / maxValue;
    for (var node in nodeList) {
      FunnelProps props = FunnelProps();
      propsMap[node] = props;
      props.p1 = Offset(0, offsetY);
      if (node.preData != null) {
        props.len1 = node.preData!.value * kw;
      } else {
        props.len1 = 0;
      }
      props.len2 = node.data.value * kw;
      props.p2 = props.p1.translate(0, itemHeight);
      offsetY = props.p2.dy + series.gap;
      if (series.align == Align2.start) {
        continue;
      }
      double topOffset = width - props.len1;
      double bottomOffset = width - props.len2;
      if (series.align == Align2.center) {
        topOffset *= 0.5;
        bottomOffset *= 0.5;
      }
      props.p1 = props.p1.translate(topOffset, 0);
      props.p2 = props.p2.translate(bottomOffset, 0);
    }
    if (series.sort == Sort.desc) {
      FunnelProps first = propsMap[nodeList.first]!;
      FunnelProps last = propsMap[nodeList.last]!;
      double diff = (last.p2.dy - first.p1.dy).abs();

      for (var node in nodeList) {
        FunnelProps props = propsMap[node]!;
        props.p1 = props.p1.scale(1, -1).translate(0, diff);
        props.p2 = props.p2.scale(1, -1).translate(0, diff);
        var t = props.p1;
        props.p1 = props.p2;
        props.p2 = t;
        var tt2 = props.len1;
        props.len1 = props.len2;
        props.len2 = tt2;
      }
    }
    for (var node in nodeList) {
      FunnelProps props = propsMap[node]!;
      node.pointList = [
        props.p1,
        props.p1.translate(props.len1, 0),
        props.p2.translate(props.len2, 0),
        props.p2,
      ];
    }
  }

  void _layoutHorizontal(List<FunnelNode> nodeList, double itemWidth) {
    double offsetX = 0;
    Map<FunnelNode, FunnelProps> propsMap = {};
    double kw = height / maxValue;
    for (var node in nodeList) {
      FunnelProps props = FunnelProps();
      propsMap[node] = props;
      props.p1 = Offset(offsetX, 0);
      if (node.preData != null) {
        props.len1 = node.preData!.value * kw;
      } else {
        props.len1 = 0;
      }
      props.len2 = node.data.value * kw;
      props.p2 = props.p1.translate(itemWidth, 0);
      offsetX = props.p2.dx + series.gap;
      if (series.align == Align2.start) {
        continue;
      }
      double leftOffset = height - props.len1;
      double rightOffset = height - props.len2;
      if (series.align == Align2.center) {
        leftOffset *= 0.5;
        rightOffset *= 0.5;
      }
      props.p1 = props.p1.translate(0, leftOffset);
      props.p2 = props.p2.translate(0, rightOffset);
    }
    if (series.sort == Sort.desc) {
      FunnelProps first = propsMap[nodeList.first]!;
      FunnelProps last = propsMap[nodeList.last]!;
      double diff = (last.p2.dx - first.p1.dx).abs();
      for (var node in nodeList) {
        FunnelProps props = propsMap[node]!;
        props.p1 = props.p1.scale(-1, 1).translate(diff, 0);
        props.p2 = props.p2.scale(-1, 1).translate(diff, 0);
        var t = props.p1;
        props.p1 = props.p2;
        props.p2 = t;
        var tt2 = props.len1;
        props.len1 = props.len2;
        props.len2 = tt2;
      }
    }
    for (var node in nodeList) {
      FunnelProps props = propsMap[node]!;
      node.pointList = [
        props.p1,
        props.p2,
        props.p2.translate(0, props.len2),
        props.p1.translate(0, props.len1),
      ];
    }
  }
}

class FunnelProps {
  Offset p1 = Offset.zero;
  double len1 = 0;
  Offset p2 = Offset.zero;
  double len2 = 0;
}
