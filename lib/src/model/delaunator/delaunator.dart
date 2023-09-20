import 'dart:math';
import 'dart:math' as math;

import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../../utils/list_util.dart';
import 'triangle.dart';

var epsilon = pow(2, -52);

List<int> edgeStack = List.filled(512, 0);

///用于 Delaunay 三角测量的快速库
/// https://mapbox.github.io/delaunator/
///移植自
///https://github.com/ricardomatias/delaunator/blob/main/src/main/kotlin/com/github/ricardomatias/Delaunator.kt
/// https://github.com/mapbox/delaunator
class Delaunator {
  List<Offset> points;
  late List<double> coords;
  late int _count;

  late int maxTriangles = math.max(2 * _count - 5, 0);
  late final List<int> _triangles = List.filled(maxTriangles * 3, 0);
  late final List<int> _halfEdges = List.filled(maxTriangles * 3, 0);

  ///顶点数据
  late List<int> triangles;

  ///半边数据
  late List<int> halfEdges;

  //用于跟踪前进凸包边缘的临时阵列
  late final int _hashSize = (sqrt(_count * 1.0)).ceil().toInt();

  late final List<int> _hullPrev = List.filled(_count, 0);
  late final List<int> _hullNext = List.filled(_count, 0);
  late final List<int> _hullTri = List.filled(_count, 0);
  late final List<int> _hullHash = List.filled(_count, 0);
  var _hullStart = -1;

  late final List<int> _ids = List.filled(_count, 0);
  late final List<double> _dists = List.filled(_count, 0.0);

  var _cx = double.nan;
  var _cy = double.nan;

  var _trianglesLen = -1;

  late List<int> hull;

  Delaunator(this.points) {
    coords = [];
    each(points, (p0, p1) {
      coords.add(p0.dx);
      coords.add(p0.dy);
    });
    _count = coords.length >> 1;
    update();
  }

  void update() {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (var i = 0; i < _count; i++) {
      var x = coords[2 * i];
      var y = coords[2 * i + 1];
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
      _ids[i] = i;
    }

    var cx = (minX + maxX) / 2;
    var cy = (minY + maxY) / 2;
    num minDist = double.infinity;

    var i0 = -1;
    var i1 = -1;
    var i2 = -1;

    for (var i = 0; i < _count; i++) {
      var d = _dist(cx, cy, coords[2 * i], coords[2 * i + 1]);
      if (d < minDist) {
        i0 = i;
        minDist = d;
      }
    }

    var i0x = coords[2 * i0];
    var i0y = coords[2 * i0 + 1];

    minDist = double.infinity;

    //找到离种子最近的点
    for (var i = 0; i < _count; i++) {
      if (i == i0) continue;
      var d = _dist(i0x, i0y, coords[2 * i], coords[2 * i + 1]);
      if (d < minDist && d > 0) {
        i1 = i;
        minDist = d;
      }
    }

    var i1x = coords[2 * i1];
    var i1y = coords[2 * i1 + 1];
    var minRadius = double.infinity;

    for (int i = 0; i < _count; i++) {
      if (i == i0 || i == i1) continue;
      var r = _circumRadius(i0x, i0y, i1x, i1y, coords[2 * i], coords[2 * i + 1]);
      if (r < minRadius) {
        i2 = i;
        minRadius = r;
      }
    }

    if (minRadius == double.infinity) {
      for (int i = 0; i < _count; i++) {
        var a = (coords[2 * i] - coords[0]);
        var b = (coords[2 * i + 1] - coords[1]);
        _dists[i] = (a == 0.0) ? b : a;
      }

      _quicksort(_ids, _dists, 0, _count - 1);

      List<int> nhull = List.filled(_count, 0);
      var j = 0;
      var d0 = double.negativeInfinity;
      for (int i = 0; i < _count; i++) {
        var id = _ids[i];
        if (_dists[id] > d0) {
          nhull[j++] = id;
          d0 = _dists[id];
        }
      }
      hull = List.from(nhull.sublist(0, math.min(j, nhull.length)));
      triangles = List.empty();
      halfEdges = List.empty();
      return;
    }

    var i2x = coords[2 * i2];
    var i2y = coords[2 * i2 + 1];

    if (_orient(i0x, i0y, i1x, i1y, i2x, i2y) < 0.0) {
      var i = i1;
      var x = i1x;
      var y = i1y;
      i1 = i2;
      i1x = i2x;
      i1y = i2y;
      i2 = i;
      i2x = x;
      i2y = y;
    }

    var center = _circumCenter(i0x, i0y, i1x, i1y, i2x, i2y);
    _cx = center.dx;
    _cy = center.dy;

    for (int i = 0; i < _count; i++) {
      _dists[i] = _dist(coords[2 * i], coords[2 * i + 1], center.dx, center.dy);
    }

    _quicksort(_ids, _dists, 0, _count - 1);

    _hullStart = i0;
    var hullSize = 3;

    _hullNext[i0] = i1;
    _hullNext[i1] = i2;
    _hullNext[i2] = i0;

    _hullPrev[i2] = i1;
    _hullPrev[i0] = i2;
    _hullPrev[i1] = i0;

    _hullTri[i0] = 0;
    _hullTri[i1] = 1;
    _hullTri[i2] = 2;

    _hullHash.fillRange(0, _hullHash.length, -1);

    _hullHash[_hashKey(i0x, i0y)] = i0;
    _hullHash[_hashKey(i1x, i1y)] = i1;
    _hullHash[_hashKey(i2x, i2y)] = i2;

    _trianglesLen = 0;
    _addTriangle(i0, i1, i2, -1, -1, -1);

    var xp = 0.0;
    var yp = 0.0;

    int indices = _ids.length;
    for (var k = 0; k < indices; k++) {
      var i = _ids[k];
      var x = coords[2 * i];
      var y = coords[2 * i + 1];

// 跳过重复点附近
      if (k > 0 && (x - xp).abs() <= epsilon && (y - yp).abs() <= epsilon) continue;

      xp = x;
      yp = y;

// 跳过种子三角形点
      if (i == i0 || i == i1 || i == i2) continue;

// 使用边哈希在凸包上找到可见边
      var start = 0;
      var key = _hashKey(x, y);

      for (var j = 0; j < _hashSize; j++) {
        start = _hullHash[(key + j) % _hashSize];
        if (start != -1 && start != _hullNext[start]) break;
      }

      start = _hullPrev[start];

      var e = start;
      var q = _hullNext[e];

      while (_orient(x, y, coords[2 * e], coords[2 * e + 1], coords[2 * q], coords[2 * q + 1]) >= 0.0) {
        e = q;
        if (e == start) {
          e = -1;
          break;
        }
        q = _hullNext[e];
      }
      if (e == -1) continue;
      var t = _addTriangle(e, i, _hullNext[e], -1, -1, _hullTri[e]);

      _hullTri[i] = _legalize(t + 2);
      _hullTri[e] = t;
      hullSize++;

      var next = _hullNext[e];
      q = _hullNext[next];

      while (_orient(x, y, coords[2 * next], coords[2 * next + 1], coords[2 * q], coords[2 * q + 1]) < 0.0) {
        t = _addTriangle(next, i, q, _hullTri[i], -1, _hullTri[next]);
        _hullTri[i] = _legalize(t + 2);
        _hullNext[next] = next;
        hullSize--;
        next = q;
        q = _hullNext[next];
      }

      if (e == start) {
        q = _hullPrev[e];
        while (_orient(x, y, coords[2 * q], coords[2 * q + 1], coords[2 * e], coords[2 * e + 1]) < 0.0) {
          t = _addTriangle(q, i, e, -1, _hullTri[e], _hullTri[q]);
          _legalize(t + 2);
          _hullTri[q] = t;
          _hullNext[e] = e; // mark as removed
          hullSize--;
          e = q;
          q = _hullPrev[e];
        }
      }

      _hullStart = e;
      _hullPrev[i] = e;
      _hullNext[e] = i;
      _hullPrev[next] = i;
      _hullNext[i] = next;

      _hullHash[_hashKey(x, y)] = i;
      _hullHash[_hashKey(coords[2 * e], coords[2 * e + 1])] = e;
    }
    hull = List.filled(hullSize, 0);
    var e = _hullStart;
    for (var i = 0; i < hullSize; i++) {
      hull[i] = e;
      e = _hullNext[e];
    }
    triangles = List.generate(_trianglesLen, (index) {
      if (index < _triangles.length) {
        return _triangles[index];
      }
      return 0;
    });
    halfEdges = List.generate(_trianglesLen, (index) {
      if (index < _halfEdges.length) {
        return _halfEdges[index];
      }
      return 0;
    });
  }

  //=========形状相关===============
  ///获取所有的三角形
  List<Triangle> getTriangle() {
    List<Triangle> rl = [];
    eachTriangle((p0, p1, p2, index) {
      rl.add(Triangle(p0, p1, p2));
    });
    return rl;
  }

  ///遍历所有的三角形(不会创建任何的三角形而是返回三角形的顶点)
  void eachTriangle(void Function(Offset, Offset, Offset, int index) call) {
    int length = triangles.length;
    for (int i = 0; i < length; i += 3) {
      var o0 = points[triangles[i]];
      var o1 = points[triangles[i + 1]];
      var o2 = points[triangles[i + 2]];
      call.call(o0, o1, o2, i);
    }
  }

  ///遍历沃罗诺伊细胞
  void eachVoronoiCell(void Function(Iterable<Offset>, int) call) {
    ///存储point ids
    Set<int> seen = {};
    for (var e = 0; e < triangles.length; e++) {
      var p = triangles[nextHalfEdge(e)];
      if (!seen.contains(p)) {
        seen.add(p);
        var edges = aroundEdgesByPoint(e);
        var triangles = edges.map(edgeToTriangle);
        var vertices = triangles.map((t) => triangleCenter(t));
        call(vertices, p);
      }
    }
  }

  void eachVoronoiCell2(void Function(Iterable<Offset>, int) call) {
    Map<int, int> index = {};
    for (var e = 0; e < triangles.length; e++) {
      var endpoint = triangles[nextHalfEdge(e)];
      if (!index.containsKey(endpoint) || halfEdges[e] == -1) {
        index[endpoint] = e;
      }
    }
    for (var p = 0; p < points.length; p++) {
      var incoming = index[p]!;
      var edges = aroundEdgesByPoint(incoming);
      var triangles = edges.map(edgeToTriangle);
      var vertices = triangles.map((t) => triangleCenter(t));
      call(vertices, p);
    }
  }

  //===============边相关========================

  ///遍历所有的三角边
  ///回调参数分别对应[startPoint,endPoint,index]
  void eachEdge(void Function(Offset, Offset, int) call) {
    for (var e = 0; e < triangles.length; e++) {
      if (e > halfEdges[e]) {
        var p = points[triangles[e]];
        var q = points[triangles[nextHalfEdge(e)]];
        call(p, q, e);
      }
    }
  }

  ///遍历沃罗诺伊边缘(类似细胞图案)
  void eachVoronoiEdge(void Function(Offset, Offset, int) call) {
    for (var e = 0; e < triangles.length; e++) {
      if (e < halfEdges[e]) {
        var p = triangleCenter(edgeToTriangle(e));
        var q = triangleCenter(edgeToTriangle(halfEdges[e]));
        call(p, q, e);
      }
    }
  }

  ///获取围绕给定点的边索引(传入边或者传出边)
  List<int> aroundEdgesByPoint(int start, [bool outEdge = false]) {
    List<int> result = [];
    int incoming = start;
    do {
      result.add(incoming);
      var outgoing = nextHalfEdge(incoming);
      incoming = halfEdges[outgoing];
    } while (incoming != -1 && incoming != start);
    if (!outEdge) {
      return result;
    }

    return List.from(result.map((e) => halfEdges[e]));
  }

  List<Offset> getPointsByPoint(int point) {
    return List.from(aroundEdgesByPoint(point).map((e) => triangles[e]));
  }

  ///给定一个点索引 返回以改点为顶点的三角形索引
  List<int> getTrianglesByPoint(int point) {
    return List.from(aroundEdgesByPoint(point).map((e) => edgeToTriangle(e)));
  }

  ///给定一个半边索引 转到其下一条半边
  int nextHalfEdge(int edgeIndex) {
    return (edgeIndex % 3 == 2) ? edgeIndex - 2 : edgeIndex + 1;
  }

  ///给定一个半边索引 转到其上一条半边
  int prevHalfEdge(int edgeIndex) {
    return (edgeIndex % 3 == 0) ? edgeIndex + 2 : edgeIndex - 1;
  }

  ///给定三角形索引返回其边的索引
  List<int> triangleToEdges(int triangleIndex) {
    return [3 * triangleIndex, 3 * triangleIndex + 1, 3 * triangleIndex + 2];
  }

  ///给定边索引 返回三角形索引
  int edgeToTriangle(int edgeIndex) {
    return (edgeIndex / 3).floor();
  }

  ///给定一个三角形索引 返回其邻接三角形索引
  List<int> getAdjacentTriangle(int triangleIndex) {
    List<int> rl = [];
    for (var e in triangleToEdges(triangleIndex)) {
      var opposite = halfEdges[e];
      if (opposite >= 0) {
        rl.add(edgeToTriangle(opposite));
      }
    }
    return rl;
  }

  ///给定三角形索引 计算其中心
  Offset triangleCenter(int triangleIndex) {
    List<Offset> vertices = List.from(triangleToPoints(triangleIndex).map((p) => points[p]));
    return _circumCenter(
      vertices[0].dx,
      vertices[0].dy,
      vertices[1].dx,
      vertices[1].dy,
      vertices[2].dx,
      vertices[2].dy,
    );
  }

  ///给定三角形索引返回顶点索引
  List<int> triangleToPoints(int triangleIndex) {
    return List.from(triangleToEdges(triangleIndex).map((e) => triangles[e]));
  }

  ///获取凸包
  List<Offset> getHull() {
    List<Offset> rl = [];
    for (var h in hull) {
      rl.add(points[h]);
    }
    return rl;
  }

  void _link(int a, int b) {
    _halfEdges[a] = b;
    if (b != -1) _halfEdges[b] = a;
  }

  int _addTriangle(int i0, int i1, int i2, int a, int b, int c) {
    var t = _trianglesLen;
    _triangles[t] = i0;
    _triangles[t + 1] = i1;
    _triangles[t + 2] = i2;
    _link(t, a);
    _link(t + 1, b);
    _link(t + 2, c);
    _trianglesLen += 3;
    return t;
  }

  int _hashKey(num x, num y) {
    return ((_pseudoAngle(x - _cx, y - _cy) * _hashSize).floor() % _hashSize).toInt();
  }

  int _legalize(int a) {
    var i = 0;
    var na = a;
    int ar;
    while (true) {
      var b = _halfEdges[na];
      var a0 = na - na % 3;
      ar = a0 + (na + 2) % 3;
      if (b == -1) {
        if (i == 0) break;
        na = edgeStack[--i];
        continue;
      }
      var b0 = b - b % 3;
      var al = a0 + (na + 1) % 3;
      var bl = b0 + (b + 2) % 3;

      int p0 = _triangles[ar];
      int pr = _triangles[na];
      int pl = _triangles[al];
      int p1 = _triangles[bl];

      var illegal = _inCircle(coords[2 * p0], coords[2 * p0 + 1], coords[2 * pr], coords[2 * pr + 1], coords[2 * pl],
          coords[2 * pl + 1], coords[2 * p1], coords[2 * p1 + 1]);
      if (illegal) {
        _triangles[na] = p1;
        _triangles[b] = p0;
        var hbl = _halfEdges[bl];
        if (hbl == -1) {
          var e = _hullStart;
          do {
            if (_hullTri[e] == bl) {
              _hullTri[e] = na;
              break;
            }
            e = _hullPrev[e];
          } while (e != _hullStart);
        }
        _link(na, hbl);
        _link(b, _halfEdges[ar]);
        _link(ar, bl);
        var br = b0 + (b + 1) % 3;
        if (i < edgeStack.length) {
          edgeStack[i++] = br;
        }
      } else {
        if (i == 0) break;
        na = edgeStack[--i];
      }
    }
    return ar;
  }
}

///顶层方法
///给定圆上三点求半径
double _circumRadius(num ax, num ay, num bx, num by, num cx, num cy) {
  var dx = bx - ax;
  var dy = by - ay;
  var ex = cx - ax;
  var ey = cy - ay;

  var bl = dx * dx + dy * dy;
  var cl = ex * ex + ey * ey;
  var d = 0.5 / (dx * ey - dy * ex);

  var x = (ey * bl - dy * cl) * d;
  var y = (dx * cl - ex * bl) * d;

  return x * x + y * y;
}

///计算圆心
Offset _circumCenter(num ax, num ay, num bx, num by, num cx, num cy) {
  var dx = bx - ax;
  var dy = by - ay;
  var ex = cx - ax;
  var ey = cy - ay;

  var bl = dx * dx + dy * dy;
  var cl = ex * ex + ey * ey;
  var d = 0.5 / (dx * ey - dy * ex);

  var x = ax + (ey * bl - dy * cl) * d;
  var y = ay + (dx * cl - ex * bl) * d;

  return Offset(x, y);
}

void _quicksort(List<int> ids, List<double> dists, int left, int right) {
  if (right - left <= 20) {
    for (var i = left + 1; i <= right; i++) {
      var temp = ids[i];
      var tempDist = dists[temp];
      var j = i - 1;
      while (j >= left && dists[ids[j]] > tempDist) {
        ids[j + 1] = ids[j--];
      }
      ids[j + 1] = temp;
    }
  } else {
    var median = (left + right) >> 1;
    var i = left + 1;
    var j = right;

    _swap(ids, median, i);

    if (dists[ids[left]] > dists[ids[right]]) _swap(ids, left, right);
    if (dists[ids[i]] > dists[ids[right]]) _swap(ids, i, right);
    if (dists[ids[left]] > dists[ids[i]]) _swap(ids, left, i);

    var temp = ids[i];
    var tempDist = dists[temp];

    while (true) {
      do {
        i++;
      } while (dists[ids[i]] < tempDist);
      do {
        j--;
      } while (dists[ids[j]] > tempDist);
      if (j < i) break;
      _swap(ids, i, j);
    }

    ids[left + 1] = ids[j];
    ids[j] = temp;

    if (right - i + 1 >= j - left) {
      _quicksort(ids, dists, i, right);
      _quicksort(ids, dists, left, j - 1);
    } else {
      _quicksort(ids, dists, left, j - 1);
      _quicksort(ids, dists, i, right);
    }
  }
}

void _swap(List<int> arr, int i, int j) {
  var tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}

num _orientIfSure(num px, num py, num rx, num ry, num qx, num qy) {
  var l = (ry - py) * (qx - px);
  var r = (rx - px) * (qy - py);

  if ((l - r).abs() >= (3.3306690738754716e-16 * (l + r).abs())) {
    return l - r;
  } else {
    return 0.0;
  }
}

num _orient(num rx, num ry, num qx, num qy, num px, num py) {
  var a = _orientIfSure(px, py, rx, ry, qx, qy);
  var b = _orientIfSure(rx, ry, qx, qy, px, py);
  var c = _orientIfSure(qx, qy, px, py, rx, ry);
  if (!_isFalsy(a)) {
    return a;
  }
  if (!_isFalsy(b)) {
    return b;
  }
  return c;
}

num _pseudoAngle(num dx, num dy) {
  var p = dx / (dx.abs() + dy.abs());
  var a = (dy > 0.0) ? 3.0 - p : 1.0 + p;
  return a / 4.0;
}

bool _inCircle(num ax, num ay, num bx, num by, num cx, num cy, num px, num py) {
  var dx = ax - px;
  var dy = ay - py;
  var ex = bx - px;
  var ey = by - py;
  var fx = cx - px;
  var fy = cy - py;

  var ap = dx * dx + dy * dy;
  var bp = ex * ex + ey * ey;
  var cp = fx * fx + fy * fy;

  return dx * (ey * cp - bp * fy) - dy * (ex * cp - bp * fx) + ap * (ex * fy - ey * fx) < 0;
}

double _dist(num ax, num ay, num bx, num by) {
  var dx = ax - bx;
  var dy = ay - by;
  return (dx * dx + dy * dy).toDouble();
}

bool _isFalsy(num? d) {
  return d == null || d == -0.0 || d == 0.0 || d.isNaN;
}
