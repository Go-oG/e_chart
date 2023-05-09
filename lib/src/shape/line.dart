import 'dart:ui';

import '../ext/path_ext.dart';
import 'shape_element.dart';

class Line implements ShapeElement {
  final List<Offset> _pointList = [];
  final double? smoothRatio;
  final List<double> _dashList=[];

  Line(List<Offset> list, {this.smoothRatio, List<double>? dashList}) {
    _pointList.addAll(list);
    if (dashList != null) {
      _dashList.addAll(dashList);
    }
  }

  Path? _closePath;
  Path? _openPath;

  @override
  Path path(bool close) {
    if (close && _closePath != null) {
      return _closePath!;
    }
    if (!close && _openPath != null) {
      return _openPath!;
    }

    Path path = Path();
    if (smoothRatio != null) {
      double smoothness = smoothRatio ?? 0.25;
      Offset firstPoint = _pointList.first;
      path.moveTo(firstPoint.dx, firstPoint.dy);
      List<Offset> controlList = _computeControlPoint(_pointList, smoothness: smoothness);
      for (int i = 0; i < (_pointList.length - 1) * 2; i += 2) {
        Offset leftControlPoint = controlList[i];
        Offset rightControlPoint = controlList[i + 1];
        Offset rightPoint = _pointList[i ~/ 2 + 1];
        path.cubicTo(leftControlPoint.dx, leftControlPoint.dy, rightControlPoint.dx, rightControlPoint.dy, rightPoint.dx, rightPoint.dy);
      }
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

  ///合并两个Path使其头相连，尾相连
  Path merge(Line l) {
    Path p1 = path(false);
    Path p2 = l.path(false);
    return mergePath(p1, p2);
  }

  ///返回平滑曲线路径(返回的路径是未封闭的)
  Path _smooth() {
    double ratioA = smoothRatio ?? 0.2;
    double ratioB = smoothRatio ?? 0.2;
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

  /// 给定上界点列表和下界点列表，返回组成的封闭的平滑区域路径
  static Path smoothArea(List<Offset> p1List, List<Offset> p2List, {double ratio = 0.2}) {
    Line line1 = Line(p1List, smoothRatio: ratio);
    Line line2 = Line(p2List, smoothRatio: ratio);
    return line1.merge(line2);
  }

  List<Offset> _computeControlPoint(List<Offset> pointList, {double smoothness = 0.25}) {
    if (smoothness <= 0 || smoothness >= 0.5) {
      smoothness = 0.25;
    }
    List<Offset> list = [];
    if (pointList.length <= 1) {
      return list;
    }
    for (int i = 0; i < pointList.length; i++) {
      Offset point = pointList[i];
      if (i == 0) {
        Offset nextPoint = pointList[i + 1];
        double controlX = point.dx + (nextPoint.dx - point.dx) * smoothness;
        double controlY = point.dy;
        list.add(Offset(controlX, controlY));
      } else if (i == pointList.length - 1) {
        Offset lastPoint = pointList[i - 1];
        double controlX = point.dx - (point.dx - lastPoint.dx) * smoothness;
        double controlY = point.dy;
        list.add(Offset(controlX, controlY));
      } else {
        Offset lastPoint = pointList[i - 1];
        Offset nextPoint = pointList[i + 1];
        double k = (nextPoint.dy - lastPoint.dy) / (nextPoint.dx - lastPoint.dx);
        double b = point.dy - k * point.dx;
        //添加前控制点
        double lastControlX = point.dx - (point.dx - lastPoint.dx) * smoothness;
        double lastControlY = k * lastControlX + b;
        list.add(Offset(lastControlX, lastControlY));
        //添加后控制点
        double nextControlX = point.dx + (nextPoint.dx - point.dx) * smoothness;
        double nextControlY = k * nextControlX + b;
        list.add(Offset(nextControlX, nextControlY));
      }
    }
    return list;
  }

  /// 根据已知点获取第i个控制点的坐标
  List<Offset> _getCtrlPoint(List<Offset> pointList, int currentIndex, {double ratioA = 0.2, double ratioB = 0.2}) {
    Offset curOffset = pointList[currentIndex];
    Offset leftOffset = pointList[currentIndex - 1];
    Offset rightOffset = pointList[currentIndex + 1];
    Offset rightOffset2 = pointList[currentIndex + 2];

    double ax = curOffset.dx + (rightOffset.dx - leftOffset.dx) * ratioA;
    double ay = curOffset.dy + (rightOffset.dy - leftOffset.dy) * ratioA;
    double bx = rightOffset.dx - (rightOffset2.dx - curOffset.dx) * ratioB;
    double by = rightOffset.dy - (rightOffset2.dy - curOffset.dy) * ratioB;
    return [Offset(ax, ay), Offset(bx, by)];
  }
}
