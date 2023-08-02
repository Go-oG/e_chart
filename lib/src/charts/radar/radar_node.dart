import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarGroupNode {
  final int groupIndex;
  final GroupData data;
  final List<RadarNode> nodeList;

  RadarGroupNode(this.groupIndex, this.data, this.nodeList);

  Path? _path;

  Path? get pathOrNull => _path;

  Path get path {
    _path ??= buildPath();
    return _path!;
  }

  void updatePath() {
    _path = buildPath();
  }

  Path buildPath() {
    Path path = Path();
    for (int i = 0; i < nodeList.length; i++) {
      RadarNode node = nodeList[i];
      if (i == 0) {
        path.moveTo(node.attr.dx, node.attr.dy);
      } else {
        path.lineTo(node.attr.dx, node.attr.dy);
      }
    }
    path.close();
    return path;
  }
}

class RadarNode extends DataNode<Offset, ItemData> {
  final RadarGroupNode parent;

  RadarNode(this.parent,ItemData data) : super(data, Offset.zero);
}
