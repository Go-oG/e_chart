import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DelaunayHelper extends LayoutHelper2<DelaunayData, DelaunaySeries> {
  static const double findRange = 16;

  DelaunayHelper(super.context, super.view, super.series);

  RBush<DelaunayData> bush = RBush.from((p0) => p0.attr.getBound());
  List<ChartOffset> hull = [];
  List<DelaunayData> showNodeList = [];

  void updateShowNodeList() {
    Rect rect = Rect.fromLTWH(-translationX, -translationY, width, height);
    showNodeList = bush.search(rect);
  }

  @override
  void onLayout(LayoutType type) {
    oldHoverData = null;
    if (series.data.isEmpty) {
      dataSet = [];
      return;
    }
    if (series.data.length > 400) {
      Future(() {
        layoutNode(series.data);
        updateShowNodeList();
        notifyLayoutUpdate();
      });
    } else {
      layoutNode(series.data);
      updateShowNodeList();
    }
  }

  void layoutNode(List<ChartOffset> dataList) {
    bool useTriangle = series.triangle;
    num left = double.maxFinite;
    num top = double.maxFinite;
    num right = double.minPositive;
    num bottom = double.minPositive;
    if (!useTriangle) {
      each(dataList, (p0, p1) {
        left = m.min(left, p0.x);
        top = m.min(top, p0.y);
        right = m.max(right, p0.x);
        bottom = m.max(bottom, p0.y);
      });
    }

    var de = Delaunay<ChartOffset>(dataList, (a) => a.x, (b) => b.y);
    hull = de.getHull();
    var hullPath = Path();
    each(hull, (p0, p1) {
      if (p1 == 0) {
        hullPath.moveTo(p0.x.toDouble(), p0.y.toDouble());
      } else {
        hullPath.lineTo(p0.x.toDouble(), p0.y.toDouble());
      }
    });
    hullPath.close();

    List<DelaunayData> resultList = [];
    de.eachShape(useTriangle, (sp, index) {
      DShape shape;
      if (useTriangle) {
        shape = DShape(index, sp);
      } else {
        ///修剪边缘
        bool has = false;
        for (var p0 in sp) {
          if (!hullPath.contains(p0.toOffset())) {
            has = true;
            break;
          }
        }
        var sd = DShape(index, sp);
        if (has) {
          sd.path = Path.combine(PathOperation.intersect, hullPath, sd.toPath());
        }
        shape = sd;
      }
      var node=DelaunayData(shape);
      node.dataIndex=index;
      node.updateStyle(context, series);
      node.updateLabelPosition(context, series);
      resultList.add(node);
    });

    bush.clear();
    bush.addAll(resultList);
    dataSet = resultList;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    updateShowNodeList();
    notifyLayoutUpdate();
  }

  @override
  DelaunayData? findData(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverData;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    var r = Rect.fromCenter(center: offset, width: findRange, height: findRange);
    var searchResult = bush.search2(r);
    for (var e in searchResult) {
      if (e.contains(offset)) {
        return e;
      }
    }
    return null;
  }
}
