import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_node.dart';

class ParallelHelper extends LayoutHelper<ParallelSeries> {
  List<ParallelNode> nodeList = [];

  ParallelHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    List<ParallelNode> oldList = nodeList;
    List<ParallelNode> newList = convertData(series.data);
    layoutNode(newList);

    var animation = series.animation;
    if (animation == null) {
      nodeList = newList;
      notifyLayoutUpdate();
      return;
    }

    Direction direction = findParallelCoord().direction;
    DiffUtil.diffLayout<List<Offset?>, ParallelGroup, ParallelNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, add) {
        List<Offset?> ol = [];
        for (var offset in node.attr) {
          if (offset == null) {
            ol.add(null);
          } else {
            double dx = direction == Direction.vertical ? 0 : offset.dx;
            double dy = direction == Direction.vertical ? offset.dy : height;
            ol.add(Offset(dx, dy));
          }
        }
        return ol;
      },
      (s, e, t) {
        List<Offset?> pl = [];
        for (int i = 0; i < s.length; i++) {
          var so = s[i];
          var eo = e[i];
          pl.add(Offset.lerp(so, eo, t));
        }
        return pl;
      },
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
    );
  }

  void layoutNode(List<ParallelNode> nodeList) {
    var coord = findParallelCoord();
    for (var node in nodeList) {
      List<Offset?> ol = [];
      for (int i = 0; i < node.data.data.length; i++) {
        var data = node.data.data[i];
        ol.add(coord.dataToPosition(i, data).center);
      }
      node.attr = ol;
    }
  }

  @override
  SeriesType get seriesType => SeriesType.parallel;

  static List<ParallelNode> convertData(List<ParallelGroup> list) {
    List<ParallelNode> nodeList = [];
    each(list, (p0, p1) {
      nodeList.add(ParallelNode(p0, p1, 0, []));
    });
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
