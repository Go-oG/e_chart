import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_node.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries, List<ParallelGroup>> {
  List<ParallelNode> nodeList = [];

  ParallelHelper(super.context, super.series);

  @override
  void onLayout(List<ParallelGroup> data, LayoutType type) {
    List<ParallelNode> oldList = nodeList;
    List<ParallelNode> newList = convertData(data);
    layoutNode(newList);
    ParallelCoord layout = context.findParallelCoord(series.parallelIndex);
    Direction direction = layout.direction;
    DiffResult<ParallelNode, ParallelGroup> result = DiffUtil.diff(oldList, newList, (p0) => p0.data, (p0, p1, newData) {
      ParallelNode node = ParallelNode(p0);
      for (var offset in p1.offsetList) {
        if (offset == null) {
          node.offsetList.add(null);
        } else {
          double dx = direction == Direction.vertical ? 0 : offset.dx;
          double dy = direction == Direction.vertical ? offset.dy : height;
          node.offsetList.add(Offset(dx, dy));
        }
      }
      return node;
    });

    Map<ParallelGroup, List<Offset?>> startMap = result.startMap.map((key, value) => MapEntry(key, value.offsetList));
    Map<ParallelGroup, List<Offset?>> endMap = result.endMap.map((key, value) => MapEntry(key, value.offsetList));

    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);

    doubleTween.startListener = () {
      nodeList = result.startList;
    };
    doubleTween.endListener = () {
      nodeList = result.endList;
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      each(result.startList, (p0, p1) {
        List<Offset?> sl = startMap[p0.data]!;
        List<Offset?> el = endMap[p0.data]!;
        double t = doubleTween.value;
        List<Offset?> pl = [];
        for (int i = 0; i < sl.length; i++) {
          if (sl[i] == null || el[i] == null) {
            pl.add(el[i]);
          } else {
            offsetTween.changeValue(sl[i]!, el[i]!);
            pl.add(offsetTween.safeGetValue(t));
          }
        }
        p0.update(pl);
      });
      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutType.update);
  }

  void layoutNode(List<ParallelNode> nodeList) {
    ParallelCoord layout = context.findParallelCoord(series.parallelIndex);
    for (var node in nodeList) {
      List<Offset?> ol = [];
      for (int i = 0; i < node.data.data.length; i++) {
        var data = node.data.data[i];
        ol.add(layout.dataToPosition(i, data).center);
      }
      node.offsetList = ol;
    }
  }


  @override
  SeriesType get seriesType => SeriesType.parallel;

  static List<ParallelNode> convertData(List<ParallelGroup> list) {
    List<ParallelNode> nodeList = [];
    for (var group in list) {
      nodeList.add(ParallelNode(group));
    }
    return nodeList;
  }
}

//数据线
class ParallelDataLine {
  final ParallelGroup group;
  final List<Offset> offsetList;
  Path? path;
  LineStyle? style;

  ParallelDataLine(this.group, this.offsetList, this.style) {
    if (style != null && offsetList.length >= 2) {
      Line line = Line(offsetList, dashList: style!.dash, smooth: style!.smooth);
      path = line.toPath(false);
    }
  }
}
