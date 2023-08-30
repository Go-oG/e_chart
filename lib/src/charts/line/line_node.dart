import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///该节点的存在是为了优化折线图在大数据量下的绘制
class LineNode {
  final int groupIndex;
  final int styleIndex;
  final LineGroupData data;
  final List<Offset?> offsetList;
  final Map<StackItemData, LineSymbolNode> symbolMap;
  final List<OptLinePath> borderList;
  final List<AreaNode> areaList;
  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  LineNode(
    this.groupIndex,
    this.styleIndex,
    this.data,
    this.offsetList,
    this.borderList,
    this.areaList,
    this.symbolMap,
  );
}

///TODO 超大数据量时需要优化
class AreaNode {
  final Area area;
  late final Rect rect;
  late final Path originPath;

  AreaNode(this.area) {
    originPath = area.toPath(true);
    rect = originPath.getBounds();
  }
}

class LineSymbolNode extends SymbolNode<StackItemData> {
  final LineGroupData group;

  LineSymbolNode(
    StackItemData data,
    ChartSymbol symbol,
    int dataIndex,
    int groupIndex,
    this.group,
  ) : super(symbol, dataIndex, groupIndex) {
    originData = data;
  }
}

class OptLinePath extends OptPath {
  final List<Offset> offsetList;

  static OptLinePath build(List<Offset> list, bool smooth, List<num> dash, [num splitLen = 500]) {
    var path = Line(list, smooth: smooth, dashList: dash).toPath(false);
    return OptLinePath(list, path, splitLen);
  }

  OptLinePath(this.offsetList, Path path, [num splitLen = 500]) : super(path, splitLen);
}
