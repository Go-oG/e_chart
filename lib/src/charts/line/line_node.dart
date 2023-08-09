import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///该节点的存在是为了优化折线图在大数据量下的绘制
class LineNode {
  final int groupIndex;
  final int styleIndex;
  final LineGroupData data;
  final List<Offset?> offsetList;
  final Map<StackItemData, SymbolNode> symbolMap;
  final List<PathNode> borderList;
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

class PathNode {
  final List<Offset> offsetList;
  late final Rect rect;
  late final Path path;
  final List<SubPath> subPathList = [];

  PathNode(this.offsetList, bool smooth, List<num> dash) {
    path = Line(offsetList, smooth: smooth, dashList: dash).toPath(false);
    rect = path.getBounds();
    double maxSize = 10000;
    for (var p in path.split(maxSize)) {
      subPathList.add(SubPath(p));
    }
  }
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

class SymbolNode extends DataNode<Offset, StackItemData> {
  final LineGroupData group;

  SymbolNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    this.group,
  );
}

class SubPath {
  final Path path;
  late final Rect bound;

  SubPath(this.path) {
    bound = path.getBounds();
  }

  SubPath.all(this.path, this.bound);
}
