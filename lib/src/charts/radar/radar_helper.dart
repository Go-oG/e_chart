import 'dart:ui';
import 'package:e_chart/e_chart.dart';

/// 雷达图布局
class RadarHelper extends LayoutHelper<RadarSeries> {
  List<RadarData> _dataList = [];

  RadarHelper(super.context, super.view, super.series);

  List<RadarData> get dataList => _dataList;

  Offset center = Offset.zero;
  double radius = 0;

  @override
  void onLayout(LayoutType type) {
    var coord = context.findRadarCoord(series.radarIndex);
    center = coord.getCenter();
    radius = coord.getRadius();

    var oldList = _dataList;
    var newList = [...series.data];
    initData(newList);
    var an = DiffUtil.diff<RadarData>(
      getAnimation(type),
      oldList,
      newList,
      (dataList) {
        each(dataList, (group, gi) {
          each(group.value, (c, i) {
            c.attr = coord.dataToPoint(i, c.value).point;
          });
          group.updatePath();
        });
      },
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
        node.scale = lerpNum(s['scale'], e['scale'], t);
      },
      (dataList, t) {
        _dataList = dataList;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
  }

  void initData(List<RadarData> dataList) {
    each(dataList, (group, gi) {
      group.groupIndex = gi;
      group.dataIndex = gi;
      group.center = center;
      group.updateStyle(context, series);
      each(group.value, (c, i) {
        c.groupIndex = gi;
        c.dataIndex = i;
        // c.attr=coord.dataToPoint(i, c.value).point;
        c.updateStyle(context, series);
      });
      group.updatePath();
    });
  }

  Map<RadarData, List<RadarChildData>> splitNode(List<RadarChildData> nodeList) {
    Map<RadarData, List<RadarChildData>> resultMap = {};
    for (var node in nodeList) {
      List<RadarChildData> nl = resultMap[node.parent] ?? [];
      resultMap[node.parent] = nl;
      nl.add(node);
    }
    return resultMap;
  }
}
