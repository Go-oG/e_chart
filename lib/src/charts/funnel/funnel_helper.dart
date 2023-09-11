import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'funnel_node.dart';

//漏斗图布局计算相关
class FunnelHelper extends LayoutHelper2<FunnelNode, FunnelSeries> {
  num maxValue = 0;

  FunnelHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    oldHoverNode = null;
    List<FunnelNode> oldList = nodeList;
    List<FunnelNode> newList = convertData(series.dataList);
    layoutNode(newList);
    var an = DiffUtil.diffLayout<List<Offset>, ItemData, FunnelNode>(getAnimation(type), oldList, newList,
        (data, node, add) {
      List<Offset> pl = node.attr;
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
        List<Offset> ol = List.from(n.attr);
        n.updatePoint(context, series, ol);
      }
      nodeList = result;
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue(an);
  }

  List<FunnelNode> convertData(List<ItemData> list) {
    List<FunnelNode> nodeList = [];
    if (list.isEmpty) {
      return nodeList;
    }
    Set<ViewState> emptyVS = {};
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      ItemData? preData = i == 0 ? null : list[i - 1];
      nodeList.add(FunnelNode(
        i,
        preData,
        data,
        i,
        series.getAreaStyle(context, data, i, emptyVS),
        series.getBorderStyle(context, data, i, emptyVS) ?? LineStyle.empty,
        series.getLabelStyle(context, data, i, emptyVS) ?? LabelStyle.empty,
      ));
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
      node.updateStyle(context, series);
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
      node.attr = [
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
      node.attr = [
        props.p1,
        props.p2,
        props.p2.translate(0, props.len2),
        props.p1.translate(0, props.len1),
      ];
    }
  }

  @override
  SeriesType get seriesType => SeriesType.funnel;

  @override
  void onRunUpdateAnimation(var list, var animation) {
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.node;
      var startAttr = diff.startAttr;
      var endAttr = diff.endAttr;
      var tween2 = ChartDoubleTween.fromValue(0, 1, props: animation);
      var s = startAttr.labelConfig?.scaleFactor ?? 1;
      var e = diff.old ? 1 : 1.1;
      tween2.addListener(() {
        var t = tween2.value;
        node.itemStyle = AreaStyle.lerp(startAttr.itemStyle, endAttr.itemStyle, t);
        node.labelConfig = node.labelConfig?.copyWith(scaleFactor: lerpDouble(s, e, t)!);
        notifyLayoutUpdate();
      });
      tl.add(tween2);
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }
}

class FunnelProps {
  Offset p1 = Offset.zero;
  double len1 = 0;
  Offset p2 = Offset.zero;
  double len2 = 0;
}
