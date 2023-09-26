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

  OptPath.not(this.path) {
    var pe = PathAttr(path);
    rect = pe.bound;
    segmentList = [pe];
  }
}

///一个优化的线段绘制
///主要解决大长度下绘制低下的问题
///目前只能在直线无dash时使用
class OptLine {
  final List<Offset> points;
  final double smooth;
  final List<SubLine> subPathList = [];
  late final double pathLength;

  OptLine(this.points, [this.smooth = 0]) {
    if (smooth <= 0) {
      pathLength = computeAllLength(points);
    } else {
      var originPath = Line(points, smooth: smooth).toPath();
      pathLength = originPath.getLength();
    }
    for (int i = 0; i < points.length - 1; i++) {
      subPathList.add(SubLine(points[i], points[i + 1], i == 0 ? 0 : subPathList[i - 1].endDis, smooth));
    }
  }

  void draw(CCanvas canvas, Paint paint, double percent) {
    double remainDis = percent * pathLength;
    int i = 0;
    while (remainDis > 0) {
      var line = subPathList[i];
      var dis = line.dis;
      if (dis <= remainDis) {
        canvas.drawLine(line.start, line.end, paint);
        remainDis -= dis;
        i++;
      } else {
        double p = remainDis / dis;
        Offset e = Offset.lerp(line.start, line.end, p)!;
        canvas.drawLine(line.start, e, paint);
        break;
      }
    }
  }

  void draw2(CCanvas canvas, Paint paint, double startP, double endP) {
    int si = findStart(startP);
    int ei = findEndStart(endP);
    double startDis = startP * pathLength;
    double endDis = endP * pathLength;
    for (int i = si; i <= ei; i++) {
      var line = subPathList[i];
      if (i == si) {
        var p = (startDis - line.startDis) / line.dis;
        var off = Offset.lerp(line.start, line.end, p)!;
        canvas.drawLine(off, line.end, paint);
      } else if (i == ei) {
        var p = (endDis - line.startDis) / line.dis;
        var off = Offset.lerp(line.start, line.end, p)!;
        canvas.drawLine(line.start, off, paint);
      } else {
        canvas.drawLine(line.start, line.end, paint);
      }
    }
  }

  double computeAllLength(List<Offset> points) {
    double l = 0;
    for (var i = 0; i < points.length - 1; i++) {
      l += points[i].distance2(points[i + 1]);
    }
    return l;
  }

  int findStart(double startP) {
    var dis = pathLength * startP;
    int i = subPathList.length ~/ 2;
    int index = -1;
    while (true && i >= 0 && i < subPathList.length) {
      var line = subPathList[i];
      if (dis == line.startDis) {
        index = i;
        break;
      }
      if (dis == line.endDis) {
        index = i + 1;
        break;
      }

      if (dis < line.startDis) {
        i = i ~/ 2;
      } else if (dis > line.endDis) {
        i = (i + points.length) ~/ 2;
      } else {
        index = i;
        break;
      }
    }

    if (index < 0) {
      index = 0;
    }
    if (index >= subPathList.length) {
      index = subPathList.length - 1;
    }
    return index;
  }

  int findEndStart(double endP) {
    var dis = pathLength * endP;
    int i = subPathList.length ~/ 2;
    int index = -1;
    while (true && i >= 0 && i < subPathList.length) {
      var line = subPathList[i];
      if (dis == line.startDis) {
        index = i - 1;
        break;
      }
      if (dis == line.endDis) {
        index = i;
        break;
      }

      if (dis < line.startDis) {
        i = i ~/ 2;
      } else if (dis > line.endDis) {
        i = (i + points.length) ~/ 2;
      } else {
        index = i;
        break;
      }
    }

    if (index < 0) {
      index = 0;
    }
    if (index >= subPathList.length) {
      index = subPathList.length - 1;
    }
    return index;
  }

}

class SubLine {
  final Offset start;
  final Offset end;
  final double startDis;
  final double smooth;
  late final double dis;
  late final double endDis;

  SubLine(this.start, this.end, this.startDis, this.smooth) {
    if(smooth<=0){
      dis = start.distance2(end);
    }else{

    }
    endDis = startDis + dis;
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
