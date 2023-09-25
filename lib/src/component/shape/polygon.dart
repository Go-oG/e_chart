import 'dart:math' as m;
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///多边形(封闭的)
/// TODO 有问题
class Polygon extends Shape {
  static final Polygon zero = Polygon([]);
  late final List<Offset> points;
  final bool pathUseHull;

  Polygon(Iterable<Offset> points, [this.pathUseHull = false]) {
    this.points = List.from(points);
  }

  Polygon.from(Iterable<ChartOffset> points, [this.pathUseHull = false]) {
    this.points = List.from(points.map((e) => e.toOffset()));
  }

  ///多边形的面积
  ///如果多边形的顶点按逆时针顺序排列（假设坐标系的原点 ⟨0，0⟩ 位于左上角）
  ///则返回的区域为正数;否则为负数或零
  double area() {
    int i = -1;
    int n = points.length;
    Offset a;
    Offset b = points[n - 1];
    double area = 0;
    while (++i < n) {
      a = b;
      b = points[i];
      area += a.dy * b.dx - a.dx * b.dy;
    }
    return area / 2;
  }

  ///返回多边形重心坐标
  Offset center() {
    int i = -1;
    int n = points.length;
    double x = 0;
    double y = 0;
    Offset a;
    Offset b = points[n - 1];
    double c;
    double k = 0;

    while (++i < n) {
      a = b;
      b = points[i];
      c = a.dx * b.dy - b.dx * a.dy;
      k += c;
      x += (a.dx + b.dx) * c;
      y += (a.dy + b.dy) * c;
    }
    k *= 3;
    return Offset(x / k, y / k);
  }

  @override
  bool contains(Offset offset) {
    if (points.isEmpty) {
      return false;
    }
    if (points.length < 3) {
      for (var c in points) {
        if (c == offset) {
          return true;
        }
      }
      return false;
    }
    if (!getBound().contains2(offset)) {
      return false;
    }
    return inInner2(offset);
    return toPath().contains(offset);
  }

  /// 返回一个点是否在一个多边形区域内
  bool inInner(Offset offset) {
    var dx = offset.dx;
    var dy = offset.dy;
    int nCross = 0;
    for (int i = 0; i < points.length; i++) {
      Offset p1 = points[i];
      Offset p2 = points[((i + 1) % points.length)];
      if (p1.dy == p2.dy) {
        continue;
      }

      if (dy < m.min(p1.dy, p2.dy)) {
        continue;
      }
      if (dy >= m.max(p1.dy, p2.dy)) {
        continue;
      }

      double x = (dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
      if (x > dx) {
        //统计单边交点
        nCross++;
      }
    }
    return (nCross % 2 == 1);
  }

  bool inInner2(Offset offset) {
    int n = points.length;
    var p = points[n - 1];
    var x = offset.dx, y = offset.dy;
    var x0 = p.dx, y0 = p.dy;

    bool inside = false;
    double x1, y1;
    for (var i = 0; i < n; ++i) {
      p = points[i];
      x1 = p.dx;
      y1 = p.dy;
      if (((y1 > y) != (y0 > y)) && (x < (x0 - x1) * (y - y1) / (y0 - y1) + x1)) {
        inside = !inside;
      }
      x0 = x1;
      y0 = y1;
    }
    return inside;
  }

  /// 返回一个点是否在一个多边形边界上
  bool inBorder(Offset offset) {
    var dx = offset.dx;
    var dy = offset.dy;
    for (int i = 0; i < points.length; i++) {
      Offset p1 = points[i];
      Offset p2 = points[((i + 1) % points.length)];
      if (dy < m.min(p1.dy, p2.dy)) {
        continue;
      }
      if (dy > m.max(p1.dy, p2.dy)) {
        continue;
      }
      if (p1.dy == p2.dy) {
        double minX = m.min(p1.dx, p2.dx);
        double maxX = m.max(p1.dx, p2.dx);
        if ((dy == p1.dy) && (dx >= minX && dx <= maxX)) {
          return true;
        }
      } else {
        // 求解交点
        double x = (dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
        if (x == dx) {
          return true;
        }
      }
    }
    return false;
  }

  ///多边形周长
  double length() {
    int i = -1;
    int n = points.length;
    Offset b = points[n - 1];
    double xa;
    double ya;
    double xb = b.dx;
    double yb = b.dy;
    double perimeter = 0;
    while (++i < n) {
      xa = xb;
      ya = yb;
      b = points[i];
      xb = b.dx;
      yb = b.dy;
      xa -= xb;
      ya -= yb;
      perimeter += hypot([xa, ya]);
    }
    return perimeter;
  }

  ///返回多边形的包裹点集合
  List<Offset> hull() {
    int n = points.length;
    if (n < 3) {
      return [];
    }

    List<Hull> sortedPoints = [];
    List<Offset> flippedPoints = [];
    for (int i = 0; i < n; ++i) {
      sortedPoints.add(Hull(points[i].dx, points[i].dy, i));
    }
    sortedPoints.sort((a, b) {
      var r = a.x.compareTo(b.x);
      if (r != 0) {
        return r;
      }
      return a.y.compareTo(b.y);
    });

    for (int i = 0; i < n; ++i) {
      flippedPoints.add(Offset(sortedPoints[i].x, -sortedPoints[i].y));
    }

    var upperIndexes = _computeUpperHullIndexes(sortedPoints);
    var lowerIndexes = _computeUpperHullIndexes(flippedPoints);

    int skipLeft = lowerIndexes[0] == upperIndexes[0] ? 1 : 0;
    int skipRight = lowerIndexes[lowerIndexes.length - 1] == upperIndexes[upperIndexes.length - 1] ? 1 : 0;
    List<Offset> hull = [];

    for (int i = upperIndexes.length - 1; i >= 0; --i) {
      hull.add(points[sortedPoints[upperIndexes[i]].i]);
    }
    for (int i = skipLeft; i < lowerIndexes.length - skipRight; ++i) {
      hull.add(points[sortedPoints[lowerIndexes[i]].i]);
    }
    return hull;
  }

  ///返回 AB AC的差积
  double _cross(Offset a, Offset b, Offset c) {
    return (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  }

  List<int> _computeUpperHullIndexes(List<dynamic> points) {
    int n = points.length;
    List<int> indexes = [0, 1];
    int size = 2;
    for (int i = 2; i < n; ++i) {
      while (size > 1) {
        dynamic a = points[indexes[size - 2]];
        if (a is Hull) {
          a = Offset(a.x, a.y);
        }
        dynamic b = points[indexes[size - 1]];
        if (b is Hull) {
          b = Offset(b.x, b.y);
        }
        dynamic c = points[i];
        if (c is Hull) {
          c = Offset(c.x, c.y);
        }
        num r = _cross(a, b, c);
        if (r <= 0) {
          --size;
        }
      }
      indexes[size++] = i;
    }
    return indexes.sublist(0, size);
  }

  @override
  bool get isClosed => true;

  Path? _path;

  Rect? _rect;

  Rect getBound() {
    if (_rect == null) {
      double left = double.maxFinite;
      double top = double.maxFinite;
      double bottom = double.minPositive;
      double right = double.minPositive;
      each(points, (p0, p1) {
        left = m.min(p0.dx, left);
        top = m.min(p0.dy, top);
        right = m.max(p0.dx, right);
        bottom = m.max(p0.dy, bottom);
      });
      _rect = Rect.fromLTRB(left, top, right, bottom);
    }
    if (_rect!.isInfinite || _rect!.isEmpty) {
      return Rect.zero;
    }
    return _rect!;
  }

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    List<Offset> ol = pathUseHull ? hull() : points;
    each(ol, (p0, p1) {
      if (p1 == 0) {
        path.moveTo2(p0);
      } else {
        path.lineTo2(p0);
      }
    });
    if (ol.length > 2) {
      path.close();
    }

    _path = path;
    return path;
  }
}

class Hull {
  final double x;
  final double y;
  final int i;

  Hull(this.x, this.y, this.i);
}
