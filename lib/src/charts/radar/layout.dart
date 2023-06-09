import 'dart:ui';
import 'package:flutter/widgets.dart';

import '../../coord/radar/radar_coord.dart';
import '../../core/context.dart';
import '../../model/group_data.dart';
import 'radar_chart.dart';

/// 雷达图布局
class RadarLayers {
  RadarGroupNode layout(RadarView view, GroupData group) {
    Context context = view.context;
    RadarCoord layout = context.findRadarCoord(view.series.radarIndex);
    RadarGroupNode groupNode = RadarGroupNode(group, []);
    int i = 0;
    for (var c in group.childData) {
      Offset offset = layout.dataToPoint(i, c.value) ?? Offset.zero;
      RadarNode radarNode = RadarNode(c, offset);
      groupNode.nodeList.add(radarNode);
      i++;
    }
    return groupNode;
  }
}

class RadarGroupNode {
  final GroupData data;
  final List<RadarNode> nodeList;
  bool show = true;

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
