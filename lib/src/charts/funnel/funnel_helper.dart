import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///漏斗图布局计算相关
class FunnelHelper extends LayoutHelper2<FunnelData, FunnelSeries> {
  num maxValue = 0;

  FunnelHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    oldHoverData = null;
    var oldList = dataSet;
    var newList = [...series.data];
    initDataIndexAndStyle(newList, true);
    var an = DiffUtil.diff<FunnelData>(
      getAnimation(type),
      oldList,
      newList,
      (dataList) => layoutNode(dataList),
      (node, type) {
        return {'scale': type == DiffType.add ? 0 : node.scale};
      },
      (node, type) {
        return {'scale': type == DiffType.remove ? 0 : 1};
      },
      (node, s, e, t, type) {
        node.scale = lerpDouble(s['scale'], e['scale'], t)!;
      },
      (dataList, t) {
        dataSet = dataList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  @override
  void initDataIndexAndStyle(List<FunnelData> dataList, [bool updateStyle = true]) {
    for (int i = 0; i < dataList.length; i++) {
      var data = dataList[i];
      var preData = i == 0 ? null : dataList[i - 1];
      data.dataIndex = i;
      data.groupIndex = 0;
      data.preData = preData;
      data.groupIndex = 0;
      if (updateStyle) {
        data.updateStyle(context, series);
      }
    }

    ///直接降序处理
    dataList.sort((a, b) {
      return a.value.compareTo(b.value);
    });
  }

  void layoutNode(List<FunnelData> nodeList) {
    maxValue = 0;
    if (nodeList.isEmpty) {
      return;
    }
    maxValue = nodeList.first.value;
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
      node.updateLabelPosition(context, series);
    }
  }

  void _layoutVertical(List<FunnelData> nodeList, double itemHeight) {
    double offsetY = 0;
    Map<FunnelData, FunnelProps> propsMap = {};
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
      props.len2 = node.value * kw;
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
      var props = propsMap[node]!;
      node.attr = [
        props.p1,
        props.p1.translate(props.len1, 0),
        props.p2.translate(props.len2, 0),
        props.p2,
      ];
    }
  }

  void _layoutHorizontal(List<FunnelData> nodeList, double itemWidth) {
    double offsetX = 0;
    Map<FunnelData, FunnelProps> propsMap = {};
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
      props.len2 = node.value * kw;
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
  void onRunUpdateAnimation(var list, var animation) {
    var tween2 = ChartDoubleTween(option: animation);
    tween2.addListener(() {
      var t = tween2.value;
      for (var diff in list) {
        var node = diff.data;
        var startAttr = diff.startAttr;
        var endAttr = diff.endAttr;
        var s = startAttr.label.scaleFactor;
        var e = diff.old ? 1 : 1.1;
        node.itemStyle = AreaStyle.lerp(startAttr.itemStyle, endAttr.itemStyle, t);
        node.label.scaleFactor = lerpDouble(s, e, t)!;
      }
      notifyLayoutUpdate();
    });
    tween2.start(context, true);
  }
}

class FunnelProps {
  Offset p1 = Offset.zero;
  double len1 = 0;
  Offset p2 = Offset.zero;
  double len2 = 0;
}
