import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///该文件存放一些性能优化使用到的类

/// 该类负责拆分Path到给定的大小
/// 在Flutter中如果一个Path 比较长且绘画时使用了[Canvas.clipxxx]相关方法则会造成卡顿
/// 解决方法是将Path 拆分为多个小的Path片断
class OptPath {
  final Path path;
  late final Rect rect;
  late final List<PathAttr> segmentList;

  OptPath(this.path, [num splitLen = 500]) {
    rect = path.getBounds();
    if (splitLen <= 0) {
      throw ChartError("splitLen must >0");
    }
    List<PathAttr> pl = [];
    for (var p in path.split(splitLen)) {
      pl.add(PathAttr(p));
    }
    segmentList = List.of(pl, growable: false);
  }

  OptPath.rect(this.path, this.rect, [num splitLen = 500]) {
    List<PathAttr> pl = [];
    for (var p in path.split(splitLen)) {
      pl.add(PathAttr(p));
    }
    segmentList = List.of(pl, growable: false);
  }

  OptPath.not(this.path){
    var pe=PathAttr(path);
    rect=pe.bound;
    segmentList=[pe];
  }
}

class PathAttr {
  final Path path;
  late final Rect bound;

  PathAttr(this.path) {
    bound = path.getBounds();
  }

  PathAttr.all(this.path, this.bound);
}

