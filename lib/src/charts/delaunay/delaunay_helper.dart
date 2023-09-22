import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DelaunayHelper extends LayoutHelper2<DelaunayNode, DelaunaySeries> {
  static const double findRange = 20;

  DelaunayHelper(super.context, super.view, super.series);

  RBush<DelaunayNode> bush = RBush.from((p0) => p0.attr.getBound());
  List<ChartOffset> hull = [];

  List<DelaunayNode> showNodeList = [];

  void updateShowNodeList() {
    Rect rect = Rect.fromLTWH(-translationX, -translationY, width, height);
  //  showNodeList = List.from(bush.search(rect).map((e) => e.value!));
    showNodeList = bush.search(rect);
    debugPrint('list:${showNodeList.length}');
  }

  @override
  void onLayout(LayoutType type) {
    oldHoverNode = null;
    if (series.data.isEmpty) {
      nodeList = [];
      return;
    }
    if (series.data.length > 400) {
      Future(() {
        layoutNode();
        updateShowNodeList();
        notifyLayoutUpdate();
      });
    } else {
      layoutNode();
      updateShowNodeList();
    }
  }

  void layoutNode() {
    bool useTriangle = series.triangle;
    num left = double.maxFinite;
    num top = double.maxFinite;
    num right = double.minPositive;
    num bottom = double.minPositive;
    if (!useTriangle) {
      each(series.data, (p0, p1) {
        left = m.min(left, p0.x);
        top = m.min(top, p0.y);
        right = m.max(right, p0.x);
        bottom = m.max(bottom, p0.y);
      });
    }
    var oldList = nodeList;

    var de = Delaunay(series.data);
    hull = de.getHull();

    List<DShape> list = [];
    de.eachShape(useTriangle, (sp, index) {
      if (useTriangle) {
        list.add(DShape(index, sp));
      } else {
        ///修剪边缘
        List<ChartOffset> ol = List.from(sp);
        // ol.removeWhere((e){
        //   return e.x>right||e.x<left||e.y>bottom||e.y<top;
        // });
        // eachRight(ol, (e, i) {
        //   if ((e.x > right || e.x < left) && i != 0) {
        //     e.x = ol[i - 1].x;
        //   }
        //   if ((e.y < top || e.y > bottom) && i != 0) {
        //     e.y = ol[i - 1].y;
        //   }
        // });
        list.add(DShape(index, ol));
      }
    });
    List<DelaunayNode> rl = [];
    each(list, (p0, p1) {
      var node = DelaunayNode(p0.points, p1, 0, p0);
      node.updateStyle(context, series);
      rl.add(node);
    });
    bush.clear();
    bush.addAll(rl);
    nodeList = rl;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    updateShowNodeList();
    notifyLayoutUpdate();
  }

  @override
  DelaunayNode? findNode(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    var sw = Stopwatch();
    sw.start();
    var searchResult = bush.search(Rect.fromCenter(center: offset, width: findRange, height: findRange));
    sw.stop();
    debugPrint('搜索量${searchResult.length} 搜索耗时:${sw.elapsedMicroseconds}ns');

    for (var e in searchResult) {
      if (e.contains(offset)) {
        return e;
      }
    }
    return null;
  }
}
