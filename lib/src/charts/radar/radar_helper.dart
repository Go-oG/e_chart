import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

import 'radar_node.dart';

/// 雷达图布局
class RadarHelper extends LayoutHelper<RadarSeries, List<GroupData>> {
  List<RadarGroupNode> _groupNodeList = [];

  RadarHelper(super.context, super.series);

  List<RadarGroupNode> get groupNodeList => _groupNodeList;

  List<RadarNode> _nodeList = [];
  Offset center = Offset.zero;
  double radius = 0;

  @override
  void onLayout(List<GroupData> data, LayoutType type) {
    RadarCoord layout = context.findRadarCoord(series.radarIndex);
    center = layout.getCenter();
    radius = layout.getRadius();

    List<RadarNode> oldList = _nodeList;
    List<RadarNode> newList = [];
    each(data, (data, gi) {
      var groupNode = RadarGroupNode(gi, data, []);
      int i = 0;
      for (var c in data.childData) {
        RadarNode radarNode = RadarNode(groupNode, c, i, gi);
        radarNode.attr = layout.dataToPoint(i, c.value).point;
        groupNode.nodeList.add(radarNode);
        i++;
      }
      newList.addAll(groupNode.nodeList);
    });

    DiffUtil.diff2(
      context,
      series.animatorProps,
      oldList,
      newList,
      (data, node, add) => center,
      (s, e, t) => Offset.lerp(s, e, t)!,
      (resultList) {
        _nodeList = resultList;
        List<RadarGroupNode> gl = List.from(splitNode(resultList).keys);
        for (var e in gl) {
          e.updatePath();
        }
        _groupNodeList = gl;
        notifyLayoutUpdate();
      },
    );
  }

  Map<RadarGroupNode, List<RadarNode>> splitNode(List<RadarNode> nodeList) {
    Map<RadarGroupNode, List<RadarNode>> resultMap = {};
    for (var node in nodeList) {
      List<RadarNode> nl = resultMap[node.parent] ?? [];
      resultMap[node.parent] = nl;
      nl.add(node);
    }
    return resultMap;
  }

  @override
  SeriesType get seriesType => SeriesType.radar;
}
