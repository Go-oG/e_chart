import 'dart:math';

import 'package:flutter/widgets.dart';

class Hex {
  static final Hex zero=Hex(0, 0, 0);
  final int q;
  final int r;
  final int s;

   Hex(this.q, this.r, this.s){
    if (q + r + s != 0) throw FlutterError("q + r + s must be 0");
  }

  Hex add(Hex b) {
    return Hex(q + b.q, r + b.r, s + b.s);
  }

  Hex subtract(Hex b) {
    return Hex(q - b.q, r - b.r, s - b.s);
  }

  Hex scale(int k) {
    return Hex(q * k, r * k, s * k);
  }

  int length() {
    return (q.abs() + r.abs() + s.abs()) ~/ 2;
  }

  int distance(Hex h) {
    return subtract(h).length();
  }

  ///向左旋转
  Hex rotateLeft() {
    return Hex(-s, -q, -r);
  }

  ///向右旋转
  Hex rotateRight() {
    return Hex(-r, -s, -q);
  }

  ///对称变换
  Hex reflectQ() {
    return Hex(q, s, r);
  }

  Hex reflectR() {
    return Hex(s, r, q);
  }

  Hex reflectS() {
    return Hex(r, q, s);
  }

  ///节点邻居变化值(逆时针)
  static final List<Hex> directions = List.from([
    Hex(1, 0, -1),
    Hex(1, -1, 0),
    Hex(0, -1, 1),
    Hex(-1, 0, 1),
    Hex(-1, 1, 0),
    Hex(0, 1, -1),
  ], growable: false);

  static Hex direction(int direction) {
    return Hex.directions[direction];
  }

  ///获取与其相连的节点(邻居节点)
  List<Hex> neighbor() {
    List<Hex> hexList = [];
    for (var hex in directions) {
      hexList.add(add(hex));
    }
    return hexList;
  }

  Hex neighbor2(int index) {
    return add(directions[index]);
  }

  ///对角线方向上的间隔节点变化值(逆时针)
  static final List<Hex> diagonals = List.from([
    Hex(2, -1, -1),
    Hex(1, -2, 1),
    Hex(-1, -1, 2),
    Hex(-2, 1, 1),
    Hex(-1, 2, -1),
    Hex(1, 1, -2),
  ], growable: false);

  static double _lerpInner(int a, int b, double t) {
    return a * (1 - t) + b * t;
  }

  static Hex lerp(Hex a, Hex b, double t) {
    var q = _lerpInner(a.q, b.q, t);
    var r = _lerpInner(a.r, b.r, t);
    var s = _lerpInner(a.s, b.s, t);
    return round(q, r, s);
  }

  static Hex round(double q, double r, double s) {
    int q2 = q.round();
    int r2 = r.round();
    int s2 = s.round();
    var qDiff = (q2 - q).abs();
    var rDiff = (r2 - r).abs();
    var sDiff = (s2 - s).abs();
    if (qDiff > rDiff && qDiff > sDiff) {
      q2 = -r2 - s2;
    } else if (rDiff > sDiff) {
      r2 = -q2 - s2;
    } else {
      s2 = -q2 - r2;
    }
    return Hex(q2, r2, s2);
  }

  ///获取特定对角线方向上的邻居节点
  ///[direction] [0,5]
  Hex diagonalNeighbor(int direction) {
    return add(Hex.diagonals[direction]);
  }

  ///返回已当前节点为中心的第N层的环节点
  List<Hex> ring(int N, [int ringStartIndex = 4, bool clockwise = false]) {
    if (N < 0) {
      throw FlutterError('N must >=0');
    }
    if (N == 0) {
      return [this];
    }
    List<Hex> results = [];
    var h1 = Hex.direction(ringStartIndex);
    var hex = add(h1.scale(N));
    for (int i = 0; i < 6; i++) {
      for (int k = 0; k < N; k++) {
        results.add(hex);
        hex = hex.neighbor2((i + (ringStartIndex - 4)) % 6);
      }
    }
    if (clockwise) {
      results = List.from(results.reversed);
    }
    return results;
  }

  ///判断当前节点是否在以[center]为中心 ,N 为半径的环上
  bool inRing(Hex center, int N) {
    Set<Hex> hexList = Set.from(center.ring(N));
    return hexList.contains(this);
  }

  ///返回连接两个节点之间的线节点
  List<Hex> line(Hex end) {
    int N = distance(end);
    List<Hex> results = [];
    double step = 1.0 / max(N, 1);
    for (int i = 0; i <= N; i++) {
      results.add(Hex.lerp(this, end, step * i));
    }
    return results;
  }

  ///将一个偏移坐标系下的位置转换为cube坐标系下的位置
  static Hex offsetCoordToHexCoord(int row, int col, {bool flat = true, bool evenLineIndent = true}) {
    int dir = evenLineIndent ? -1 : 1;
    if (flat) {
      var q = col;
      var r = (row - (col + dir * (col & 1)) / 2).toInt();
      return Hex(q, r, -q - r);
    } else {
      var q = (col - (row + dir * (row & 1)) / 2).toInt();
      var r = row;
      return Hex(q, r, -q - r);
    }
  }

  @override
  String toString() {
    return '$q $r $s';
  }

  @override
  int get hashCode {
    return Object.hash(q, r, s);
  }

  @override
  bool operator ==(Object other) {
    return other is Hex && other.q == q && other.r == r && other.s == s;
  }
}
