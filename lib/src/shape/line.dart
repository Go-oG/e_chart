import 'dart:ui';

import 'package:e_chart/src/ext/index.dart';
import '../model/constans.dart';
import 'chart_shape.dart';

class Line implements Shape {
  final List<Offset> _pointList = [];
  final bool smooth;
  final List<num> _dashList = [];

  Line(List<Offset> list, {this.smooth = false, List<num>? dashList}) {
    _pointList.addAll(list);
    if (dashList != null) {
      _dashList.addAll(dashList);
    }
  }

  Path? _closePath;
  Path? _openPath;

  List<Offset> get pointList => _pointList;

  @override
  Path toPath(bool close) {
    if (close && _closePath != null) {
      return _closePath!;
    }
    if (!close && _openPath != null) {
      return _openPath!;
    }
    Path path = Path();
    if (smooth) {
      path = _smooth();
    } else {
      Offset first = _pointList.first;
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < _pointList.length; i++) {
        Offset p = _pointList[i];
        path.lineTo(p.dx.toDouble(), p.dy.toDouble());
      }
    }
    if (close) {
      path.close();
    }
    if (_dashList.isNotEmpty) {
      path = dashPath(path, _dashList);
    }

    if (close) {
      _closePath = path;
    } else {
      _openPath = path;
    }
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
    num ratioA = Constants.smoothRatio;
    num ratioB = Constants.smoothRatio;
    Path path = Path();
    Offset firstPoint = _pointList.first;
    path.moveTo(firstPoint.dx, firstPoint.dy);
    //添加前后点
    List<Offset> tmpList = [];
    tmpList.add(_pointList[0]);
    tmpList.addAll(_pointList);
    tmpList.add(_pointList.last);
    tmpList.add(_pointList.last);
    for (int i = 1; i < tmpList.length - 3; i++) {
      List<Offset> list = _getCtrlPoint(tmpList, i, ratioA: ratioA, ratioB: ratioB);
      Offset leftPoint = list[0];
      Offset rightPoint = list[1];
      Offset p = tmpList[i + 1];
      path.cubicTo(leftPoint.dx, leftPoint.dy, rightPoint.dx, rightPoint.dy, p.dx, p.dy);
    }
    return path;
  }

  /// 根据已知点获取第i个控制点的坐标
  List<Offset> _getCtrlPoint(List<Offset> pointList, int curIndex, {num ratioA = 0.2, num ratioB = 0.2, bool reverse = false}) {
    Offset cur = pointList[curIndex];

    int li = reverse ? curIndex + 1 : curIndex - 1;
    int ri = reverse ? curIndex - 1 : curIndex + 1;
    int ri2 = reverse ? curIndex - 2 : curIndex + 2;

    Offset left = pointList[li];
    Offset right = pointList[ri];
    Offset right2 = pointList[ri2];

    double ax = cur.dx + (right.dx - left.dx) * ratioA;
    double ay = cur.dy + (right.dy - left.dy) * ratioA;
    double bx = right.dx - (right2.dx - cur.dx) * ratioB;
    double by = right.dy - (right2.dy - cur.dy) * ratioB;

    return [Offset(ax, ay), Offset(bx, by)];
  }

  @override
  bool internal(Offset offset) {
    Path path = toPath(false);
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      double i = 0;
      while (i < metric.length) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          Offset p = tangent.position;
          if (offset.distance2(p) <= 2) {
            return true;
          }
        }
        i++;
      }
    }
    return false;
  }
}
