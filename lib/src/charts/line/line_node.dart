import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///该节点的存在是为了优化折线图在大数据量下的绘制
class LineNode {
  final int groupIndex;
  final LineGroupData data;
  final List<Offset?> offsetList;
  final Map<LineItemData, SymbolNode> symbolMap;
  final List<PathNode> borderList;
  final List<AreaNode> areaList;
  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  LineNode(
    this.groupIndex,
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
  late final Path smoothPath;

  final List<SubPath> subPathList = [];
  final List<SubPath> subSmoothPathList = [];

  PathNode(this.offsetList) {
    path = Line(offsetList, smooth: false).toPath(false);
    rect = path.getBounds();
    smoothPath = Line(offsetList, smooth: true).toPath(false);
    double maxSize = 4000;
    for (var p in path.split(maxSize)) {
      subPathList.add(SubPath(p));
    }
    for (var p in smoothPath.split(maxSize)) {
      subSmoothPathList.add(SubPath(p));
    }
  }
}

class AreaNode {
  final Area area;
  late final Rect rect;
  late final Path originPath;

  AreaNode(this.area) {
    originPath = area.toPath(true);
    rect = originPath.getBounds();
  }

  final Map<int, Path> _areaMap = {};

  List<Path> getAreaPath(double w, double h, Offset scroll) {
    if (rect.width <= w) {
      return [area.toPath(true)];
    }
    int start = (scroll.dx.abs()) ~/ w;
    int end = (scroll.dx.abs() + w) ~/ w;
    if ((scroll.dx.abs() + w) % w != 0) {
      end += 1;
    }
    List<Path> pathList = [];
    Path clipPath = Path();
    for (int i = start; i < end; i++) {
      Path? path = _areaMap[i];
      if (path != null) {
        pathList.add(path);
        continue;
      }
      clipPath.reset();
      double s = i * w;
      double e = (i + 1) * w;
      clipPath.moveTo(s, 0);
      clipPath.lineTo(e, 0);
      clipPath.lineTo(e, h);
      clipPath.lineTo(s, h);
      clipPath.close();
      path = Path.combine(PathOperation.intersect, clipPath, originPath);
      _areaMap[i] = path;
      pathList.add(path);
    }
    return pathList;
  }

  void preCacheAreaPath(int start, int end, double w, double h, [bool sync = true]) {
    if (rect.width <= w) {
      return;
    }
    List<int> intList = [];
    for (int i = start; i < end; i++) {
      Path? path = _areaMap[i];
      if (path != null) {
        continue;
      }
      intList.add(i);
    }
    if (sync) {
      _areaMap.addAll(_buildAreaPath(intList, w, h));
    } else {
      Future<Map<int, Path>>(() {
        return _buildAreaPath(intList, w, h);
      }).then((value) {
        _areaMap.addAll(value);
      });
    }
  }

  Map<int, Path> _buildAreaPath(List<int> list, double w, double h) {
    Map<int, Path> map = {};
    Path clipPath = Path();
    for (var i in list) {
      clipPath.reset();
      double s = i * w;
      double e = (i + 1) * w;
      clipPath.moveTo(s, 0);
      clipPath.lineTo(e, 0);
      clipPath.lineTo(e, h);
      clipPath.lineTo(s, h);
      clipPath.close();
      map[i] = Path.combine(PathOperation.intersect, clipPath, originPath);
    }
    return map;
  }
}

class SymbolNode {
  final Offset offset;
  final LineItemData data;
  final LineGroupData group;
  final int groupIndex;

  const SymbolNode(this.offset, this.data, this.group, this.groupIndex);
}

class SubPath {
  final Path path;
  late final Rect bound;

  SubPath(this.path) {
    bound = path.getBounds();
  }

  SubPath.all(this.path, this.bound);
}
