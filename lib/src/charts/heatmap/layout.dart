import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/animation.dart';

import '../../animation/index.dart';
import '../../coord/index.dart';
import '../../core/index.dart';
import '../../model/index.dart';
import 'heat_map_node.dart';
import 'heat_map_series.dart';

class HeatMapLayout extends ChartLayout {
  List<HeatMapNode> _nodeList = [];

  List<HeatMapNode> get nodeList => _nodeList;

  num width = 0;
  num height = 0;
  late Context context;
  late HeatMapSeries series;

  void doLayout(Context context, HeatMapSeries series, List<HeatMapData> dataList, num width, num height, bool useUpdate) {
    this.context = context;
    this.series = series;
    this.width = width;
    this.height = height;
    _layoutInner(dataList, useUpdate);
  }

  void _layoutInner(List<HeatMapData> dataList, bool useUpdate) {
    Map<HeatMapData, HeatMapNode> oldMap = {};
    each(_nodeList, (p0, p1) {
      oldMap[p0.data] = p0;
    });
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordSystem == CoordSystem.grid) {
      gridLayout = context.findGridCoord();
    } else {
      calendarLayout = context.findCalendarCoord(series.xAxisIndex);
    }
    List<HeatMapNode> nodeList = [];
    Map<HeatMapData, HeatMapNode> nodeMap = {};
    for (var data in series.data) {
      Rect? rect;
      if (gridLayout != null) {
        rect = gridLayout.dataToPoint(series.xAxisIndex, data.x, series.yAxisIndex, data.y);
      } else if (calendarLayout != null) {
        rect = calendarLayout.dataToPoint(data.x.data);
      }
      if (rect == null) {
        throw ChartError('无法布局 $gridLayout  $calendarLayout');
      }
      HeatMapNode node = HeatMapNode(data);
      node.rect = rect;
      nodeList.add(node);
      nodeMap[data] = node;
    }

    Set<HeatMapData> removeSet = {};
    Set<HeatMapData> addSet = {};
    Set<HeatMapData> commonSet = {};
    oldMap.forEach((key, value) {
      if (!nodeMap.containsKey(key)) {
        removeSet.add(key);
      } else {
        commonSet.add(key);
      }
    });
    nodeMap.forEach((key, value) {
      if (!oldMap.containsKey(key)) {
        addSet.add(key);
      } else {
        commonSet.add(key);
      }
    });

    for (var key in removeSet) {
      Offset center = oldMap[key]!.rect.center;
      HeatMapNode tmp = HeatMapNode(key);
      tmp.rect = Rect.fromCenter(center: center, width: 0, height: 0);
      nodeMap[key] = tmp;
    }
    for (var key in addSet) {
      Offset center = nodeMap[key]!.rect.center;
      HeatMapNode tmp = HeatMapNode(key);
      tmp.rect = Rect.fromCenter(center: center, width: 0, height: 0);
      oldMap[key] = tmp;
    }

    ChartRectTween rectTween = ChartRectTween(Rect.zero, Rect.zero);
    ChartDoubleTween doubleTween = ChartDoubleTween(props: series.animatorProps);

    doubleTween.startListener = () {
      _nodeList = List.from(oldMap.values);
    };

    doubleTween.addListener(() {
      var v = doubleTween.value;
      oldMap.forEach((key, value) {
        rectTween.changeValue(value.rect, nodeMap[key]!.rect);
        Rect rect = rectTween.safeGetValue(v);
        value.rect = rect;
      });
      notifyLayoutUpdate();
    });

    doubleTween.endListener = () {
      _nodeList.removeWhere((element) => removeSet.contains(element.data));
    };
    doubleTween.start(context, useUpdate);
  }
}
