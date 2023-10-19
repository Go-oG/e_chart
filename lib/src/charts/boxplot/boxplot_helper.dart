import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BoxplotHelper extends GridHelper<BoxplotData, BoxplotGroup, BoxplotSeries> {
  BoxplotHelper(super.context, super.view, super.series);

  static const String _borderListK = "borderList";
  static const String _boxRectK = "boxRectK";
  static const String _minCK = "minC";
  static const String _downCK = "downC";
  static const String _middleCK = "middleC";
  static const String _upCK = "upC";
  static const String _maxCK = "maxC";
  static const String _colRectK = "colRect";

  @override
  dynamic getNodeUpValue(SingleNode<BoxplotData, BoxplotGroup> node) {
    return node.originData!.max;
  }

  @override
  dynamic getNodeDownValue(SingleNode<BoxplotData, BoxplotGroup> node) {
    return node.originData!.min;
  }

  @override
  void onLayoutNode(var columnNode, LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    final Rect colRect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      var data = node.originData;
      if (data == null) {
        continue;
      }
      var group = node.parent;
      Offset minC = _computeOffset(colRect, data.min, group.xAxisIndex, vertical);
      Offset downC = _computeOffset(colRect, data.downAve4, group.xAxisIndex, vertical);
      Offset middleC = _computeOffset(colRect, data.middle, group.xAxisIndex, vertical);
      Offset upC = _computeOffset(colRect, data.upAve4, group.xAxisIndex, vertical);
      Offset maxC = _computeOffset(colRect, data.max, group.xAxisIndex, vertical);

      node.extSet(_minCK, minC);
      node.extSet(_downCK, downC);
      node.extSet(_middleCK, middleC);
      node.extSet(_upCK, upC);
      node.extSet(_maxCK, maxC);
      _setPath(node, vertical, minC, downC, middleC, upC, maxC, colRect);
    }
  }

  @override
  StackAnimatorNode onCreateAnimatorNode(var node, DiffType diffType, bool isStart) {

    if (diffType == DiffType.update ||
        (diffType == DiffType.remove && isStart) ||
        (diffType == DiffType.add && !isStart)) {
      var an = StackAnimatorNode();
      an.extSetAll(node.extGetAll());
      return an;
    }

    Offset middleOffset = node.extGet(_middleCK);
    var an = StackAnimatorNode();
    an.extSet(_colRectK, node.extGet(_colRectK));
    an.extSet(_minCK, middleOffset);
    an.extSet(_downCK, middleOffset);
    an.extSet(_middleCK, middleOffset);
    an.extSet(_upCK, middleOffset);
    an.extSet(_maxCK, middleOffset);
    return an;
  }

  @override
  void onAnimatorUpdate(var node, double t, var startStatus, var endStatus) {
    var s = startStatus;
    var e = endStatus;
    Rect colRect = s.extGet(_colRectK);
    Offset smino = s.extGet(_minCK);
    Offset sdowno = s.extGet(_downCK);
    Offset smiddleo = s.extGet(_middleCK);
    Offset suo = s.extGet(_upCK);
    Offset smaxo = s.extGet(_maxCK);
    Offset emino = e.extGet(_minCK);
    Offset edowno = e.extGet(_downCK);
    Offset emiddleo = e.extGet(_middleCK);
    Offset euo = e.extGet(_upCK);
    Offset emaxo = e.extGet(_maxCK);
    Offset mino = Offset.lerp(smino, emino, t)!;
    Offset downo = Offset.lerp(sdowno, edowno, t)!;
    Offset middleo = Offset.lerp(smiddleo, emiddleo, t)!;
    Offset upo = Offset.lerp(suo, euo, t)!;
    Offset maxo = Offset.lerp(smaxo, emaxo, t)!;
    _setPath(node, series.direction == Direction.vertical, mino, downo, middleo, upo, maxo, colRect);
    node.updateLabelPosition(context, series);
  }

  void _setPath(
    SingleNode<BoxplotData, BoxplotGroup> node,
    bool vertical,
    Offset minC,
    Offset downC,
    Offset middleC,
    Offset upC,
    Offset maxC,
    Rect colRect,
  ) {
    double tx = vertical ? colRect.width / 2 : 0;
    double ty = vertical ? 0 : colRect.height / 2;

    node.extSet(_colRectK, colRect);
    Rect boxRect;
    Rect areaRect;
    List<List<Offset>> borderList = [];

    if (vertical) {
      boxRect = Rect.fromPoints(maxC.translate(-tx, 0), minC.translate(tx, 0));
      areaRect = Rect.fromPoints(upC.translate(-tx, 0), downC.translate(tx, 0));
      borderList
          .add([areaRect.bottomLeft, areaRect.bottomRight, areaRect.topRight, areaRect.topLeft, areaRect.bottomLeft]);
      borderList.add([minC, downC]);
      borderList.add([upC, maxC]);
      for (var c in [minC, maxC, middleC]) {
        borderList.add([c.translate(-tx, 0), c.translate(tx, 0)]);
      }
    } else {
      boxRect = Rect.fromPoints(minC.translate(0, -ty), maxC.translate(0, ty));
      areaRect = Rect.fromPoints(downC.translate(0, -ty), upC.translate(0, ty));
      borderList.add([minC, downC]);
      borderList
          .add([areaRect.bottomLeft, areaRect.bottomRight, areaRect.topRight, areaRect.topLeft, areaRect.bottomLeft]);
      borderList.add([upC, maxC]);
      for (var c in [minC, maxC, middleC]) {
        borderList.add([c.translate(0, -ty), c.translate(0, ty)]);
      }
    }
    node.rect = areaRect;
    node.extSet(_borderListK, borderList);
    node.extSet(_boxRectK, boxRect);
  }

  Offset _computeOffset(Rect colRect, num data, int axisIndex, bool vertical) {
    var coord = findGridCoord();
    if (vertical) {
      return Offset((colRect.left + colRect.right) / 2, coord.dataToPoint(axisIndex, data, false).first.dy);
    }
    return Offset(
      coord.dataToPoint(axisIndex, data, true).first.dx,
      (colRect.top + colRect.bottom) / 2,
    );
  }

  List<List<Offset>> getBorderList(SingleNode<BoxplotData, BoxplotGroup> node) {
    return node.extGet(_borderListK);
  }

  Rect getAreaRect(SingleNode<BoxplotData, BoxplotGroup> node) {
    return node.rect;
  }
}
