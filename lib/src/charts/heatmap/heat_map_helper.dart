import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import 'heat_map_node.dart';

class HeatMapHelper extends LayoutHelper2<HeatMapNode, HeatMapSeries> {
  HeatMapHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    List<HeatMapNode> oldList = nodeList;
    List<HeatMapNode> newList = convertData(series.data);
    layoutNode(newList);
    each(newList, (node, p1) {
      node.updateStyle(context, series);
    });
    var an = DiffUtil.diffLayout2<HeatMapNode>(
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (node, add) => add ? 0 : node.symbol.scale,
      (node, add) => add ? 1 : 0,
      (node, t) => node.symbol.scale = t,
      (resultList, t) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  List<HeatMapNode> convertData(List<HeatMapData> dataList) {
    List<HeatMapNode> rl = [];
    each(dataList, (e, i) {
      var node = HeatMapNode(e, i);
      rl.add(node);
    });
    return rl;
  }

  void layoutNode(List<HeatMapNode> nodeList) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordType == CoordType.grid) {
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
        rect = calendarLayout.dataToPosition(data.x);
      }
      if (rect == null) {
        throw ChartError('无法布局 $gridLayout  $calendarLayout');
      }
      node.attr = rect;
      //文字
      var label = data.name;
      if (label != null) {
        node.label = TextDraw(label, LabelStyle.empty, TextDraw.offsetByRect(node.attr, node.labelAlign),
            align: TextDraw.alignConvert(node.labelAlign));
      } else {
        node.label = TextDraw.empty;
      }
    }
  }
}
