import 'dart:ui';

import 'package:e_chart/e_chart.dart';

//K线图
class CandlestickHelper extends GridHelper<CandleStickData, CandleStickGroup, CandleStickSeries> {
  static const String _colRectK = "colRectK";
  static const String _borderListK = "borderListK";
  static const String _boxRectK = "boxRectK";

  static const String _openK = "open";
  static const String _closeK = "close";
  static const String _highK = "high";
  static const String _lowK = "low";

  CandlestickHelper(super.context, super.view, super.series);

  @override
  void onLayoutNode(var columnNode, LayoutType type) {
    final Rect colRect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      var data = node.dataNull;
      if (data == null) {
        continue;
      }
      var group = node.parent;
      Offset lowC = _computeOffset(colRect, data.lowest, group.domainAxis);
      Offset highC = _computeOffset(colRect, data.highest, group.domainAxis);
      Offset openC = _computeOffset(colRect, data.open, group.domainAxis);
      Offset closeC = _computeOffset(colRect, data.close, group.domainAxis);
      node.extSet(_lowK, lowC);
      node.extSet(_highK, highC);
      node.extSet(_openK, openC);
      node.extSet(_closeK, closeC);
      _setPath(node, lowC, highC, openC, closeC, colRect);
    }
  }

  void _setPath(StackData<CandleStickData, CandleStickGroup> node, Offset lowC, Offset highC, Offset openC,
      Offset closeC, Rect colRect) {
    final double tx = colRect.width / 2;

    node.extSet(_colRectK, colRect);
    Rect boxRect = Rect.fromPoints(highC.translate(-tx, 0), lowC.translate(tx, 0));
    Rect areaRect;
    if (node.data.isUp) {
      areaRect = Rect.fromPoints(closeC.translate(-tx, 0), openC.translate(tx, 0));
    } else {
      areaRect = Rect.fromPoints(openC.translate(-tx, 0), closeC.translate(tx, 0));
    }

    List<List<Offset>> borderList = [];
    borderList
        .add([areaRect.bottomLeft, areaRect.bottomRight, areaRect.topRight, areaRect.topLeft, areaRect.bottomLeft]);
    if (node.data.isUp) {
      borderList.add([lowC, openC]);
      borderList.add([closeC, highC]);
    } else {
      borderList.add([lowC, closeC]);
      borderList.add([openC, highC]);
    }
    node.rect = areaRect;
    node.extSet(_borderListK, borderList);
    node.extSet(_boxRectK, boxRect);
  }

  Offset _computeOffset(Rect colRect, num data, int axisIndex) {
    var coord = findGridCoord();
    List<Offset> ol = coord.dataToPoint(axisIndex, data, false);
    return Offset(colRect.left, ol.first.dy);
  }

  @override
  StackAnimatorNode onCreateAnimatorNode(var node, DiffType diffType, bool isStart) {
    if (node.dataIsNull) {
      return StackAnimatorNode();
    }

    if (diffType == DiffType.update ||
        (diffType == DiffType.remove && isStart) ||
        (diffType == DiffType.add && !isStart)) {
      var an = StackAnimatorNode();
      an.extSetAll(node.extGetAll());
      return an;
    }

    Offset tmp = node.extGet(_openK);
    var an = StackAnimatorNode();
    an.extSet(_colRectK, node.extGet(_colRectK));
    an.extSet(_lowK, tmp);
    an.extSet(_openK, tmp);
    an.extSet(_closeK, tmp);
    an.extSet(_highK, tmp);
    return an;
  }

  @override
  void onAnimatorUpdate(var node, double t, var startStatus, var endStatus) {
    var s = startStatus;
    var e = endStatus;

    Rect colRect = s.extGet(_colRectK);
    Offset soo = s.extGet(_openK);
    Offset sco = s.extGet(_closeK);
    Offset sho = s.extGet(_highK);
    Offset slo = s.extGet(_lowK);

    Offset eoo = e.extGet(_openK);
    Offset eco = e.extGet(_closeK);
    Offset eho = e.extGet(_highK);
    Offset elo = e.extGet(_lowK);

    Offset oo = Offset.lerp(soo, eoo, t)!;
    Offset co = Offset.lerp(sco, eco, t)!;
    Offset ho = Offset.lerp(sho, eho, t)!;
    Offset lo = Offset.lerp(slo, elo, t)!;
    _setPath(node, lo, ho, oo, co, colRect);
  }

  @override
  List<dynamic> getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale<dynamic, num> scale) {
    if (isXAxis) {
      return super.getViewPortAxisExtreme(axisIndex, isXAxis, scale);
    }
    if (scale.isCategory || scale.isTime) {
      throw ChartError("K线图只支持num");
    }
    var result = super.getViewPortAxisExtreme(axisIndex, isXAxis, scale);
    if (result.length < 2) {
      return result;
    }

    List<num> dl = [];
    for (var d in result) {
      if (d is num) {
        dl.add(d);
      }
    }
    if (dl.length < 2) {
      return result;
    }
    dl.sort();
    var dlMin = dl.first;
    var dlMax = dl.last;

    var mainMax = scale.domain.last as num;
    var mainMin = scale.domain.first as num;
    num rMin, rMax;
    if (dlMin <= mainMin * 1.2 && dlMin >= mainMin) {
      rMin = mainMin;
    } else {
      rMin = dlMin;
    }
    if (dlMax <= mainMax && dlMax >= mainMax * 0.8) {
      rMax = mainMax;
    } else {
      rMax = dlMax;
    }
    return [rMin, rMax];
  }

  List<List<Offset>> getBorderList(StackData<CandleStickData, CandleStickGroup> node) {
    return node.extGet(_borderListK);
  }

  Rect getAreaRect(StackData<CandleStickData, CandleStickGroup> node) {
    return node.rect;
  }

  @override
  StackData<CandleStickData, CandleStickGroup>? findData(Offset offset, [bool overlap = false]) {
    var node = super.findData(offset);
    if (node != null) {
      return node;
    }
    for (var node in dataSet) {
      List<List<Offset>> bl = node.extGetNull(_borderListK) ?? [];
      for (var l in bl) {
        if (offset.inPolygon(l)) {
          return node;
        }
      }
    }
    for (var node in series.getHelper(context).dataList) {
      List<List<Offset>> bl = node.extGetNull(_borderListK) ?? [];
      for (var l in bl) {
        if (offset.inPolygon(l)) {
          return node;
        }
      }
    }
    return null;
  }
}
