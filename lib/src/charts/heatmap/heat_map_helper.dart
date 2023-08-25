import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import 'heat_map_node.dart';

class HeatMapHelper extends LayoutHelper<HeatMapSeries> {
  List<HeatMapNode> _nodeList = [];

  HeatMapHelper(super.context, super.series);

  List<HeatMapNode> get nodeList => _nodeList;

  @override
  void onLayout(LayoutType type) {
    List<HeatMapNode> oldList = _nodeList;
    List<HeatMapNode> newList = convertData(series.data);
    layoutNode(newList);
    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      _nodeList = newList;
      return ;
    }
    DiffUtil.diffLayout<Rect, HeatMapData, HeatMapNode>(
      context,
      animation,
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
  void onClick(Offset localOffset) {
    handleHoverOrClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHoverOrClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHoverOrClick(localOffset, false);
  }

  @override
  void onHoverEnd() {}

  HeatMapNode? _hoverNode;

  void handleHoverOrClick(Offset offset, bool click) {
    var oldOffset = offset;
    Offset scroll;
    if (series.coordType == CoordType.grid) {
      scroll = findGridCoord().getScroll();
    } else {
      scroll = findCalendarCoord().getScroll();
    }
    offset = offset.translate(scroll.dx.abs(), scroll.dy.abs());
    var clickNode = findNode(offset);
    if (_hoverNode == clickNode) {
      return;
    }

    var oldNode = _hoverNode;
    _hoverNode = clickNode;
    if (oldNode != null) {
      sendHoverOutEvent(oldNode.data, dataIndex: oldNode.dataIndex, groupIndex: oldNode.groupIndex);
    }
    if (clickNode != null) {
      click
          ? sendClickEvent(oldOffset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex)
          : sendHoverInEvent(oldOffset, clickNode.data,
              dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
    }
    oldNode?.removeState(ViewState.hover);
    clickNode?.addState(ViewState.hover);
    notifyLayoutUpdate();
  }

  HeatMapNode? findNode(Offset offset) {
    for (var node in _nodeList) {
      if (node.attr.contains2(offset)) {
        return node;
      }
    }
    return null;
  }

  @override
  SeriesType get seriesType => SeriesType.heatmap;
}
