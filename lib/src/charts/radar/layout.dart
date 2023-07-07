import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/widgets.dart';

import '../../coord/radar/radar_coord.dart';
import '../../core/layout.dart';
import '../../model/group_data.dart';
import 'radar_series.dart';

/// 雷达图布局
class RadarLayout extends ChartLayout<RadarSeries, List<GroupData>> {
  List<RadarGroupNode> _groupNodeList = [];

  List<RadarGroupNode> get groupNodeList => _groupNodeList;

  Offset center = Offset.zero;
  double radius = 0;

  @override
  void onLayout(List<GroupData> data, LayoutAnimatorType type) {
    RadarCoord layout = context.findRadarCoord(series.radarIndex);
    center = layout.getCenter();
    radius = layout.getRadius();
    List<RadarGroupNode> gl = [];
    each(data, (data, p1) {
      var groupNode = RadarGroupNode(data, []);
      gl.add(groupNode);
      int i = 0;
      for (var c in data.childData) {
        Offset offset = layout.dataToPoint(i, c.value).point;
        RadarNode radarNode = RadarNode(c, offset);
        groupNode.nodeList.add(radarNode);
        i++;
      }
    });
    _groupNodeList = gl;
  }
}

class RadarGroupNode {
  final GroupData data;
  final List<RadarNode> nodeList;

  RadarGroupNode(this.data, this.nodeList);

  Path buildPath() {
    Path path = Path();
    for (int i = 0; i < nodeList.length; i++) {
      RadarNode node = nodeList[i];
      if (i == 0) {
        path.moveTo(node.cur.dx, node.cur.dy);
      } else {
        path.lineTo(node.cur.dx, node.cur.dy);
      }
    }
    path.close();
    return path;
  }

  List<Offset> getPathOffset() {
    List<Offset> list = [];
    for (int i = 0; i < nodeList.length; i++) {
      RadarNode node = nodeList[i];
      list.add(node.cur);
    }
    return list;
  }
}

class RadarNode {
  final ItemData data;
  final Offset offset;
  Offset cur = Offset.zero;
  Offset start = Offset.zero;
  Offset end = Offset.zero;

  RadarNode(this.data, this.offset) {
    cur = offset;
    start = offset;
    end = offset;
  }
}
