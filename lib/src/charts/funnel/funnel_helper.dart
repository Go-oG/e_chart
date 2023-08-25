//漏斗图布局计算相关
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'funnel_node.dart';

class FunnelHelper extends LayoutHelper<FunnelSeries> {
  List<FunnelNode> nodeList = [];

  num maxValue = 0;

  FunnelHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    _hoverNode = null;
    List<FunnelNode> oldList = nodeList;
    List<FunnelNode> newList = convertData(series.dataList);
    layoutNode(newList);
    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      nodeList = newList;
      return;
    }

    DiffUtil.diffLayout<List<Offset>, ItemData, FunnelNode>(context, animation, oldList, newList, (data, node, add) {
      List<Offset> pl = node.pointList;
      Offset o0 = Offset((pl[0].dx + pl[1].dx) / 2, (pl[0].dy + pl[3].dy) / 2);
      return [o0, o0, o0, o0];
    }, (s, e, t) {
      List<Offset> pl = [];
      for (int i = 0; i < 4; i++) {
        pl.add(Offset.lerp(s[i], e[i], t)!);
      }
      return pl;
    }, (result) {
      for (var n in result) {
        List<Offset> ol = List.from(n.pointList);
        n.updatePoint(context, series, ol);
      }
      nodeList = List.from(result);
      notifyLayoutUpdate();
    });
  }

  List<FunnelNode> convertData(List<ItemData> list) {
    List<FunnelNode> nodeList = [];
    if (list.isEmpty) {
      return nodeList;
    }
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      ItemData? preData = i == 0 ? null : list[i - 1];
      nodeList.add(FunnelNode(i, preData, data, i));
    }

    ///直接降序处理
    nodeList.sort((a, b) {
      return a.data.value.compareTo(b.data.value);
    });
    return nodeList;
  }

  void layoutNode(List<FunnelNode> nodeList) {
    maxValue = 0;
    if (nodeList.isEmpty) {
      return;
    }
    maxValue = nodeList.first.data.value;

    if (series.maxValue != null && maxValue < series.maxValue!) {
      maxValue = series.maxValue!;
    }
    int count = nodeList.length;
    double gapAllHeight = (count - 1) * series.gap;
    num size = series.direction == Direction.vertical ? height : width;
    double itemSize = (size - gapAllHeight) / count;
    if (series.itemHeight != null) {
      itemSize = series.itemHeight!.convert(height);
    }
    if (series.direction == Direction.vertical) {
      _layoutVertical(nodeList, itemSize);
    } else {
      _layoutHorizontal(nodeList, itemSize);
    }

    for (var node in nodeList) {
      node.update(context, series);
    }
  }

  void _layoutVertical(List<FunnelNode> nodeList, double itemHeight) {
    double offsetY = 0;
    Map<FunnelNode, FunnelProps> propsMap = {};
    double kw = width / maxValue;
    for (var node in nodeList) {
      FunnelProps props = FunnelProps();
      propsMap[node] = props;
      props.p1 = Offset(0, offsetY);
      if (node.preData != null) {
        props.len1 = node.preData!.value * kw;
      } else {
        props.len1 = 0;
      }
      props.len2 = node.data.value * kw;
      props.p2 = props.p1.translate(0, itemHeight);
      offsetY = props.p2.dy + series.gap;
      if (series.align == Align2.start) {
        continue;
      }
      double topOffset = width - props.len1;
      double bottomOffset = width - props.len2;
      if (series.align == Align2.center) {
        topOffset *= 0.5;
        bottomOffset *= 0.5;
      }
      props.p1 = props.p1.translate(topOffset, 0);
      props.p2 = props.p2.translate(bottomOffset, 0);
    }
    if (series.sort == Sort.desc) {
      FunnelProps first = propsMap[nodeList.first]!;
      FunnelProps last = propsMap[nodeList.last]!;
      double diff = (last.p2.dy - first.p1.dy).abs();

      for (var node in nodeList) {
        FunnelProps props = propsMap[node]!;
        props.p1 = props.p1.scale(1, -1).translate(0, diff);
        props.p2 = props.p2.scale(1, -1).translate(0, diff);
        var t = props.p1;
        props.p1 = props.p2;
        props.p2 = t;
        var tt2 = props.len1;
        props.len1 = props.len2;
        props.len2 = tt2;
      }
    }
    for (var node in nodeList) {
      FunnelProps props = propsMap[node]!;
      node.pointList = [
        props.p1,
        props.p1.translate(props.len1, 0),
        props.p2.translate(props.len2, 0),
        props.p2,
      ];
    }
  }

  void _layoutHorizontal(List<FunnelNode> nodeList, double itemWidth) {
    double offsetX = 0;
    Map<FunnelNode, FunnelProps> propsMap = {};
    double kw = height / maxValue;
    for (var node in nodeList) {
      FunnelProps props = FunnelProps();
      propsMap[node] = props;
      props.p1 = Offset(offsetX, 0);
      if (node.preData != null) {
        props.len1 = node.preData!.value * kw;
      } else {
        props.len1 = 0;
      }
      props.len2 = node.data.value * kw;
      props.p2 = props.p1.translate(itemWidth, 0);
      offsetX = props.p2.dx + series.gap;
      if (series.align == Align2.start) {
        continue;
      }
      double leftOffset = height - props.len1;
      double rightOffset = height - props.len2;
      if (series.align == Align2.center) {
        leftOffset *= 0.5;
        rightOffset *= 0.5;
      }
      props.p1 = props.p1.translate(0, leftOffset);
      props.p2 = props.p2.translate(0, rightOffset);
    }
    if (series.sort == Sort.desc) {
      FunnelProps first = propsMap[nodeList.first]!;
      FunnelProps last = propsMap[nodeList.last]!;
      double diff = (last.p2.dx - first.p1.dx).abs();
      for (var node in nodeList) {
        FunnelProps props = propsMap[node]!;
        props.p1 = props.p1.scale(-1, 1).translate(diff, 0);
        props.p2 = props.p2.scale(-1, 1).translate(diff, 0);
        var t = props.p1;
        props.p1 = props.p2;
        props.p2 = t;
        var tt2 = props.len1;
        props.len1 = props.len2;
        props.len2 = tt2;
      }
    }
    for (var node in nodeList) {
      FunnelProps props = propsMap[node]!;
      node.pointList = [
        props.p1,
        props.p2,
        props.p2.translate(0, props.len2),
        props.p1.translate(0, props.len1),
      ];
    }
  }

  FunnelNode? _hoverNode;

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

  void handleHoverOrClick(Offset offset, bool click) {
    bool result = false;
    Map<FunnelNode, AreaStyle> oldMap = {};
    Map<FunnelNode, LabelStyle> oldMap2 = {};
    FunnelNode? hoverNode;
    for (var node in nodeList) {
      oldMap[node] = node.areaStyle;
      if (node.labelStyle != null) {
        oldMap2[node] = node.labelStyle!;
      }
      if (node.path.contains(offset)) {
        hoverNode = node;
        if (node.addState(ViewState.hover)) {
          result = true;
        }
      } else {
        if (node.removeState(ViewState.hover)) {
          result = true;
        }
      }
    }
    if (!result) {
      return;
    }

    if (_hoverNode == hoverNode) {
      if (hoverNode != null) {
        if (click) {
          sendClickEvent(offset, hoverNode.data, dataIndex: hoverNode.dataIndex, groupIndex: hoverNode.groupIndex);
        } else {
          sendHoverInEvent(offset, hoverNode.data, dataIndex: hoverNode.dataIndex, groupIndex: hoverNode.groupIndex);
        }
      }
      return;
    }

    final old = _hoverNode;
    _hoverNode = hoverNode;
    if (old != null) {
      sendHoverOutEvent(old.data, dataIndex: old.dataIndex, groupIndex: old.groupIndex);
    }
    if (hoverNode != null) {
      if (click) {
        sendClickEvent(offset, hoverNode.data, dataIndex: hoverNode.dataIndex, groupIndex: hoverNode.groupIndex);
      } else {
        sendHoverInEvent(offset, hoverNode.data, dataIndex: hoverNode.dataIndex, groupIndex: hoverNode.groupIndex);
      }
    }

    var animator = series.animation;
    if (animator == null || animator.updateDuration.inMilliseconds <= 0) {
      old?.textConfig = old.textConfig?.copyWith(scaleFactor: 1);
      hoverNode?.textConfig = hoverNode.textConfig?.copyWith(scaleFactor: 1.5);
      notifyLayoutUpdate();
      return;
    }

    List<ChartTween> tl = [];
    if (old != null && oldMap.containsKey(old)) {
      AreaStyle style = getAreaStyle(context, series, old);
      AreaStyleTween tween = AreaStyleTween(oldMap[old]!, style, props: animator);
      tween.addListener(() {
        old.areaStyle = tween.value;
        notifyLayoutUpdate();
      });
      tl.add(tween);
      ChartDoubleTween tween2 =
          ChartDoubleTween.fromValue((old.textConfig?.scaleFactor ?? 1).toDouble(), 1, props: animator);
      tween2.addListener(() {
        old.textConfig = old.textConfig?.copyWith(scaleFactor: tween2.value);
        notifyLayoutUpdate();
      });
      tl.add(tween2);
    }
    if (hoverNode != null) {
      var node = hoverNode;
      AreaStyle style = getAreaStyle(context, series, node);
      AreaStyleTween tween = AreaStyleTween(oldMap[node]!, style, props: animator);
      tween.addListener(() {
        node.areaStyle = tween.value;
        notifyLayoutUpdate();
      });
      tl.add(tween);
      ChartDoubleTween tween2 =
          ChartDoubleTween.fromValue((node.textConfig?.scaleFactor ?? 1).toDouble(), 1.5, props: animator);
      tween2.addListener(() {
        node.textConfig = node.textConfig?.copyWith(scaleFactor: tween2.value);
        notifyLayoutUpdate();
      });
      tl.add(tween2);
    }
    if (tl.isEmpty) {
      notifyLayoutUpdate();
      return;
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  @override
  void onHoverEnd() {
    var old = _hoverNode;
    _hoverNode = null;
    if (old == null) {
      return;
    }
    sendHoverOutEvent(old.data, dataIndex: old.dataIndex, groupIndex: old.groupIndex);

    var animation = series.animation;
    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      old.removeState(ViewState.hover);
      old.areaStyle = getAreaStyle(context, series, old).convert(old.status);
      notifyLayoutUpdate();
      return;
    }

    List<ChartTween> tl = [];
    AreaStyle oldStyle = old.areaStyle;
    old.removeState(ViewState.hover);
    AreaStyle style = getAreaStyle(context, series, old).convert(old.status);
    AreaStyleTween tween = AreaStyleTween(oldStyle, style, props: animation);
    tween.addListener(() {
      old.areaStyle = tween.value;
      notifyLayoutUpdate();
    });
    tl.add(tween);
    ChartDoubleTween tween2 =
        ChartDoubleTween.fromValue((old.textConfig?.scaleFactor ?? 1).toDouble(), 1, props: animation);
    tween2.addListener(() {
      old.textConfig = old.textConfig?.copyWith(scaleFactor: tween2.value);
    });
    tl.add(tween2);
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  static AreaStyle getAreaStyle(Context context, FunnelSeries series, FunnelNode node) {
    return series.getAreaStyle(context, node.data, node.dataIndex);
  }

  static LineStyle? getBorderStyle(Context context, FunnelSeries series, FunnelNode node) {
    return series.getBorderStyle(context, node.data, node.dataIndex);
  }

  @override
  SeriesType get seriesType => SeriesType.funnel;
}

class FunnelProps {
  Offset p1 = Offset.zero;
  double len1 = 0;
  Offset p2 = Offset.zero;
  double len2 = 0;
}
