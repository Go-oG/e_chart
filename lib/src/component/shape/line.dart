import 'dart:ui';

import 'package:e_chart/src/ext/index.dart';

import '../../static_config.dart';
import '../../utils/assert_check.dart';
import 'chart_shape.dart';

class Line implements Shape {
  final List<Offset> _pointList = [];
  final num smooth;
  final List<num> _dashList = [];
  final num disDiff;

  Line(
    List<Offset> list, {
    this.smooth = 0,
    List<num>? dashList,
    this.disDiff = 2,
  }) {
    _pointList.addAll(list);
    if (dashList != null) {
      _dashList.addAll(dashList);
    }
  }

  Path? _path;

  List<Offset> get pointList => _pointList;

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    if (smooth>0) {
      path = _smooth();
    } else {
      Offset first = _pointList.first;
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < _pointList.length; i++) {
        Offset p = _pointList[i];
        path.lineTo(p.dx, p.dy);
      }
    }
    if (_dashList.isNotEmpty) {
      path = path.dashPath(_dashList);
    }
    _path = path;
    return path;
  }

  /// 返回其 step图形样式坐标点
  List<Offset> step([double ratio = 0.5]) {
    if (_pointList.length <= 1) {
      return [..._pointList];
    }
    List<Offset> list = [];
    for (int i = 0; i < _pointList.length - 1; i++) {
      Offset cur = _pointList[i];
      Offset next = _pointList[i + 1];
      list.add(cur);
      double x = (cur.dx + next.dx) * ratio;
      list.add(Offset(x, cur.dy));
      list.add(Offset(x, next.dy));
    }
    list.add(_pointList[_pointList.length - 1]);
    return list;
  }

  /// 返回其 step图形样式(after)坐标点
  List<Offset> stepAfter() {
    if (_pointList.length <= 1) {
      return [..._pointList];
    }
    List<Offset> list = [];

    for (int i = 0; i < _pointList.length - 1; i++) {
      Offset cur = _pointList[i];
      Offset next = _pointList[i + 1];
      list.add(cur);
      list.add(Offset(next.dx, cur.dy));
    }
    list.add(_pointList[_pointList.length - 1]);
    return list;
  }

  ///返回其 step图形样式(before)坐标点
  List<Offset> stepBefore() {
    if (_pointList.length <= 1) {
      return [..._pointList];
    }
    int n = _pointList.length - 1;
    List<Offset> list = [];
    for (int i = 0; i < n; i++) {
      Offset cur = _pointList[i];
      Offset next = _pointList[i + 1];
      list.add(cur);
      list.add(Offset(cur.dx, next.dy));
    }
    list.add(_pointList[n]);
    return list;
  }

  ///返回平滑曲线路径(返回的路径是未封闭的)
  Path _smooth() {
    Path path = Path();
    if (_pointList.isEmpty) {
      return path;
    }
    Offset firstPoint = _pointList.first;
    path.moveTo(firstPoint.dx, firstPoint.dy);
    for (int i = 0; i < _pointList.length - 1; i++) {
      Offset cur = _pointList[i];
      Offset next = _pointList[i + 1];
      List<Offset> cl = _getCtrPoint(cur, next);
      if (cl.length != 2) {
        path.lineTo(next.dx, next.dy);
      } else {
        var c1 = cl[0];
        var c2 = cl[1];
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, next.dx, next.dy);
      }
    }
    return path;
  }

  ///获取贝塞尔曲线控制点
  List<Offset> _getCtrPoint(Offset start, Offset end) {
    var v = StaticConfig.smoothRatio;
    assertCheck(v >= 0 && v <= 1, "smoothRatio must >=0&&<=1 ");
    if (start.dx == end.dx || start.dy == end.dy) {
      return [];
    }
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double c1x = start.dx + dx * v;
    double c1y = start.dy + dy * v;
    double c2x = end.dx - dx * v;
    double c2y = end.dy - dy * v;
    return [Offset(c1x, c1y), Offset(c2x, c2y)];
  }

  @override
  bool contains(Offset offset) {
    Path path = toPath();
    if (path.contains(offset)) {
      return true;
    }
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      double i = 0;
      while (i < metric.length) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          Offset p = tangent.position;
          if (offset.distance2(p) <= disDiff) {
            return true;
          }
        }
        i++;
      }
    }
    return false;
  }

  ///将该段线条追加到Path的后面
  void appendToPathEnd(Path path) {
    if (_pointList.isEmpty) {
      return;
    }
    Offset firstPoint = _pointList.first;
    path.lineTo(firstPoint.dx, firstPoint.dy);
    for (int i = 0; i < _pointList.length - 1; i++) {
      Offset cur = _pointList[i];
      Offset next = _pointList[i + 1];
      List<Offset> cl = _getCtrPoint(cur, next);
      if (cl.length != 2) {
        path.lineTo(next.dx, next.dy);
      } else {
        var c1 = cl[0];
        var c2 = cl[1];
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, next.dx, next.dy);
      }
    }
  }

  @override
  bool get isClosed => false;
}
