import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

class DelaunayHelper extends LayoutHelper2<DelaunayNode, DelaunaySeries> {
  static const double findRange = 20;

  DelaunayHelper(super.context, super.view, super.series);

  RBush<DelaunayNode> bush = RBush();

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
    var oldList = nodeList;
    bush.clear();
    var de = Delaunay(series.data);
    List<DShape> list = de.getShape(series.triangle);
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
