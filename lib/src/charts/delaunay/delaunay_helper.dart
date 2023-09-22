import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

class DelaunayHelper extends LayoutHelper2<DelaunayNode, DelaunaySeries> {
  static const double findRange = 20;

  DelaunayHelper(super.context, super.view, super.series);

  RBush<DelaunayNode> bush = RBush();
  List<ChartOffset> hull=[];

  Iterable<DelaunayNode> getShowNodeList() {
    Rect rect = Rect.fromLTWH(-translationX, -translationY, width, height);
    return bush.search(rect).map((e) => e.data!);
  }

  @override
  void onLayout(LayoutType type) {
    oldHoverNode = null;
    if (series.data.isEmpty) {
      nodeList = [];
      return;
    }
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
    bush.clear();
    var de = Delaunay(series.data);
    hull=de.getHull();

    List<DShape> list = [];
    de.eachShape(useTriangle, (sp, index) {
      if (useTriangle) {
        list.add(DShape(index, sp));
      } else {
        ///修剪边缘
        List<ChartOffset> ol = List.from(sp);
        debugPrint('$ol');

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
    List<RNode<DelaunayNode>> itemList = [];
    each(list, (p0, p1) {
      var node = DelaunayNode(p0.points, p1, 0, p0, AreaStyle.empty, LineStyle.empty, LabelStyle.empty);
      rl.add(node);
      RNode<DelaunayNode> item = RNode.fromRect(p0.getBound());
      item.data = node;
      itemList.add(item);
      node.updateStyle(context, series);
    });
    bush.addAll(itemList);
    nodeList = rl;
  }

  @override
  DelaunayNode? findNode(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    var searchResult = bush.search(Rect.fromCenter(center: offset, width: findRange, height: findRange));
    for (var e in searchResult) {
      if (e.data!.contains(offset)) {
        return e.data!;
      }
    }
    return null;
  }
}
