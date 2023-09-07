import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import 'heat_map_node.dart';

class HeatMapHelper extends LayoutHelper2<HeatMapNode, HeatMapSeries> {
  HeatMapHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    List<HeatMapNode> oldList = nodeList;
    List<HeatMapNode> newList = convertData(series.data);
    layoutNode(newList);
    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      nodeList = newList;
      return;
    }
    var an = DiffUtil.diffLayout<Rect, HeatMapData, HeatMapNode>(
      animation,
      oldList,
      newList,
      (data, node, add) => Rect.fromCenter(center: node.attr.center, width: 0, height: 0),
      (s, e, t) => Rect.lerp(s, e, t)!,
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
    );
    context.addAnimationToQueue(an);
  }

  List<HeatMapNode> convertData(List<HeatMapData> dataList) {
    List<HeatMapNode> rl = [];
    each(dataList, (e, i) {
      var node = HeatMapNode(e, i, AreaStyle.empty, LineStyle.empty, LabelStyle.empty);
      node.updateStyle(context, series);
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
    }
  }

  @override
  SeriesType get seriesType => SeriesType.heatmap;

  @override
  void onRunUpdateAnimation(var oldNode, var oldAttr, var newNode, var newAttr, var animation) {
    List<ChartTween> tl = [];
    if (oldNode != null) {
      var oldStyle = oldAttr!.itemStyle;
      var style = oldNode.itemStyle;
      AreaStyleTween tween = AreaStyleTween(oldStyle, style, props: animation);
      tween.addListener(() {
        oldNode.itemStyle = tween.value;
        notifyLayoutUpdate();
      });
      tl.add(tween);
    }
    if (newNode != null) {
      var oldStyle = newAttr!.itemStyle;
      var style = newNode.itemStyle;
      var tween = AreaStyleTween(oldStyle, style, props: animation);
      tween.addListener(() {
        newNode.itemStyle = tween.value;
        notifyLayoutUpdate();
      });
      tl.add(tween);
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }
}
