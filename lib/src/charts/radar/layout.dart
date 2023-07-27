import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

/// 雷达图布局
class RadarLayout extends ChartLayout<RadarSeries, List<GroupData>> {
  List<RadarGroupNode> _groupNodeList = [];
  List<RadarGroupNode> get groupNodeList => _groupNodeList;
  List<RadarNode> nodeList = [];
  Offset center = Offset.zero;
  double radius = 0;

  @override
  void onLayout(List<GroupData> data, LayoutType type) {
    RadarCoord layout = context.findRadarCoord(series.radarIndex);
    center = layout.getCenter();
    radius = layout.getRadius();

    List<RadarNode> nodeList = [];
    List<RadarGroupNode> gl = [];
    each(data, (data, p1) {
      var groupNode = RadarGroupNode(p1,data, []);
      gl.add(groupNode);
      int i = 0;
      for (var c in data.childData) {
        Offset offset = layout.dataToPoint(i, c.value).point;
        RadarNode radarNode = RadarNode(c, offset);
        groupNode.nodeList.add(radarNode);
        i++;
      }
      nodeList.addAll(groupNode.nodeList);
    });
    _groupNodeList = gl;

    DiffResult<RadarNode, ItemData> result = DiffUtil.diff(this.nodeList, nodeList, (p0) => p0.data, (p0, p1, newData) {
      return RadarNode(p0, center);
    });
    Map<ItemData, Offset> startMap = result.startMap.map((key, value) => MapEntry(key, value.offset));
    Map<ItemData, Offset> endMap = result.endMap.map((key, value) => MapEntry(key, value.offset));

    OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);
    ChartDoubleTween doubleTween = ChartDoubleTween(props: series.animatorProps);
    doubleTween.startListener = () {
      this.nodeList = result.curList;
    };
    doubleTween.endListener = () {
      this.nodeList = result.finalList;
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      var v = doubleTween.value;
      each(result.curList, (p0, p1) {
        offsetTween.changeValue(startMap[p0.data]!, endMap[p0.data]!);
        p0.offset = offsetTween.safeGetValue(v);
      });
      each(gl, (group, p1) {
        group.updatePath();
      });

      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutType.update);
  }
}

class RadarGroupNode {
  final int groupIndex;
  final GroupData data;
  final List<RadarNode> nodeList;

  RadarGroupNode(this.groupIndex,this.data, this.nodeList);

  Path? _path;

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
        path.moveTo(node.offset.dx, node.offset.dy);
      } else {
        path.lineTo(node.offset.dx, node.offset.dy);
      }
    }
    path.close();
    return path;
  }

}

class RadarNode {
  final ItemData data;
  Offset offset;

  RadarNode(this.data, this.offset);
}
