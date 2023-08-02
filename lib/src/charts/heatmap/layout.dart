import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import 'heat_map_node.dart';

class HeatMapLayout extends ChartLayout<HeatMapSeries, List<HeatMapData>> {
  List<HeatMapNode> _nodeList = [];

  List<HeatMapNode> get nodeList => _nodeList;

  @override
  void onLayout(List<HeatMapData> data, LayoutType type) {
    List<HeatMapNode> oldList = _nodeList;
    List<HeatMapNode> newList = convertData(data);
    layoutNode(newList);
    DiffUtil.diff2<Rect, HeatMapData, HeatMapNode>(
      context,
      series.animatorProps,
      oldList,
      newList,
      (data, node, add) => Rect.fromCenter(center: node.attr.center, width: 0, height: 0),
      (s, e, t) => Rect.lerp(s, e, t)!,
      (resultList) {
        _nodeList = resultList;
        notifyLayoutUpdate();
      },
    );
  }

  List<HeatMapNode> convertData(List<HeatMapData> dataList) {
    List<HeatMapNode> rl = [];
    each(dataList, (e, i) {
      rl.add(HeatMapNode(e, i));
    });

    return rl;
  }

  void layoutNode(List<HeatMapNode> nodeList) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordSystem == CoordSystem.grid) {
      gridLayout = findGridCoord();
    } else {
      calendarLayout = findCalendarCoord();
    }
    for (var node in nodeList) {
      var data = node.data;
      Rect? rect;
      if (gridLayout != null) {
        rect = gridLayout.dataToRect(0, data.x, 0, data.y);
      } else if (calendarLayout != null) {
        rect = calendarLayout.dataToPosition(data.x.data);
      }
      if (rect == null) {
        throw ChartError('无法布局 $gridLayout  $calendarLayout');
      }
      node.attr = rect;
    }
  }

  @override
  SeriesType get seriesType => SeriesType.heatmap;
}
