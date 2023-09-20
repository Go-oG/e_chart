import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import 'radar_node.dart';

/// 雷达图布局
class RadarHelper extends LayoutHelper<RadarSeries> {
  List<RadarGroupNode> _groupNodeList = [];

  RadarHelper(super.context, super.view, super.series);

  List<RadarGroupNode> get groupNodeList => _groupNodeList;

  Offset center = Offset.zero;
  double radius = 0;

  @override
  void onLayout(LayoutType type) {
    var coord = context.findRadarCoord(series.radarIndex);
    center = coord.getCenter();
    radius = coord.getRadius();

    List<RadarGroupNode> oldList = _groupNodeList;
    List<RadarGroupNode> newList = [];
    each(series.data, (group, gi) {
      var groupNode = RadarGroupNode(
        [],
        group,
        gi,
        0,
        RadarGroupNode.emptyPath,
        series.getAreaStyle(context, group, gi, {}) ?? AreaStyle.empty,
        series.getLineStyle(context, group, gi, {}) ?? LineStyle.empty,
        LabelStyle.empty,
      );
      groupNode.center = center;
      each(group.data, (c, i) {
        var radarNode = RadarNode(groupNode, series.getSymbol(context, c, group, i, {}), c, i, gi);
        radarNode.attr = coord.dataToPoint(i, c.value).point;
        groupNode.nodeList.add(radarNode);
      });
      groupNode.updatePath();
      newList.add(groupNode);
    });
    var an = DiffUtil.diffLayout3(
      getAnimation(type),
      oldList,
      newList,
      (node, type) {
        if (type == DiffType.add) {
          return {"scale": 0};
        } else {
          return {'scale': node.scale};
        }
      },
      (node, type) {
        if (type == DiffType.remove) {
          return {"scale": 0};
        } else {
          return {"scale": 1};
        }
      },
      (node, s, e, t, type) {
        node.scale = lerpDouble(s['scale'] as num, e['scale'] as num, t)!;
      },
      (resultList) {
        _groupNodeList = resultList;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
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

}
