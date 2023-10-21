import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///该节点的存在是为了优化折线图在大数据量下的绘制
class LineNode {
  final int groupIndex;
  final LineGroupData data;
  final List<Offset?> offsetList;
  final Map<StackData, LineSymbolNode> symbolMap;
  final List<OptLinePath> borderList;
  final List<AreaNode> areaList;
  AreaStyle areaStyle = AreaStyle.empty;
  LineStyle lineStyle = LineStyle.empty;

  LineNode(
    this.groupIndex,
    this.data,
    this.offsetList,
    this.borderList,
    this.areaList,
    this.symbolMap,
    this.areaStyle,
    this.lineStyle,
  );
}

///TODO 超大数据量时需要优化
class AreaNode {
  final Area area;
  late final Rect rect;
  late final Path originPath;

  AreaNode(this.area) {
    originPath = area.toPath();
    rect = originPath.getBounds();
  }
}

class LineSymbolNode extends SymbolNode<StackData> {
  final LineGroupData group;

  LineSymbolNode(
    this.group,
    super.data,
    super.symbol,
    super.dataIndex,
    super.groupIndex,
  );
}

class OptLinePath extends OptPath {
  final List<Offset> offsetList;

  static OptLinePath build(List<Offset> list, num smooth, List<num> dash, [num splitLen = 500]) {
    var path = Line(list, smooth: smooth, dashList: dash).toPath();
    return OptLinePath(list, path, splitLen);
  }

  OptLinePath(this.offsetList, Path path, [num splitLen = 500]) : super(path, splitLen);
}
