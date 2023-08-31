import 'dart:math';

import 'package:flutter/material.dart';

import '../../graph/layout/force/lcg.dart';
import '../pack_node.dart';

extension PackNodeExt on PackNode {
  toCircle() {
    return PackCircle(x.toDouble(), y.toDouble(), r);
  }
}

PackCircle packEncloseRandom(List<PackNode> circles, LCG random) {
  shuffle(circles, random);
  int i = 0, n = circles.length;
  List<PackCircle> B = [];
  PackCircle? e;
  while (i < n) {
    PackNode p = circles[i];
    var pc = p.toCircle();
    if (e != null && enclosesWeak(e, pc)) {
      i++;
    } else {
      e = encloseBasis(B = extendBasis(B, pc));
      i = 0;
    }
  }
  return e!;
}

List<PackCircle> extendBasis(List<PackCircle> B, PackCircle pc) {
  int i, j;
  if (enclosesWeakAll(pc, B)) {
    return [pc];
  }

  // If we get here then B must have at least one element.
  for (i = 0; i < B.length; ++i) {
    if (enclosesNot(pc, B[i]) && enclosesWeakAll(encloseBasis2(B[i], pc), B)) {
      return [B[i], pc];
    }
  }

  // If we get here then B must have at least two elements.
  for (i = 0; i < B.length - 1; ++i) {
    for (j = i + 1; j < B.length; ++j) {
      if (enclosesNot(encloseBasis2(B[i], B[j]), pc) &&
          enclosesNot(encloseBasis2(B[i], pc), B[j]) &&
          enclosesNot(encloseBasis2(B[j], pc), B[i]) &&
          enclosesWeakAll(encloseBasis3(B[i], B[j], pc), B)) {
        return [B[i], B[j], pc];
      }
    }
  }

  // If we get here then something is very wrong.
  throw FlutterError('异常');
}

bool enclosesNot(PackCircle a, PackCircle b) {
  var dr = a.r - b.r, dx = b.x - a.x, dy = b.y - a.y;
  return dr < 0 || dr * dr < dx * dx + dy * dy;
}

bool enclosesWeak(PackCircle a, PackCircle b) {
  num maxV = max(a.r, b.r);
  maxV = max(maxV, 1);
  var dr = a.r - b.r + maxV * 1e-9, dx = b.x - a.x, dy = b.y - a.y;
  return dr > 0 && dr * dr > dx * dx + dy * dy;
}

bool enclosesWeakAll(PackCircle a, List<PackCircle> B) {
  for (var i = 0; i < B.length; ++i) {
    if (!enclosesWeak(a, B[i])) {
      return false;
    }
  }
  return true;
}

PackCircle? encloseBasis(List<PackCircle> B) {
  switch (B.length) {
    case 1:
      return encloseBasis1(B[0]);
    case 2:
      return encloseBasis2(B[0], B[1]);
    case 3:
      return encloseBasis3(B[0], B[1], B[2]);
  }
  return null;
}

PackCircle encloseBasis1(PackCircle a) {
  return PackCircle(a.x.toDouble(), a.y.toDouble(), a.r);
}

PackCircle encloseBasis2(PackCircle a, PackCircle b) {
  var x1 = a.x,
      y1 = a.y,
      r1 = a.r,
      x2 = b.x,
      y2 = b.y,
      r2 = b.r,
      x21 = x2 - x1,
      y21 = y2 - y1,
      r21 = r2 - r1,
      l = sqrt(x21 * x21 + y21 * y21);
  return PackCircle(
    (x1 + x2 + x21 / l * r21) / 2,
    (y1 + y2 + y21 / l * r21) / 2,
    (l + r1 + r2) / 2,
  );
}

PackCircle encloseBasis3(PackCircle a, PackCircle b, PackCircle c) {
  var x1 = a.x,
      y1 = a.y,
      r1 = a.r,
      x2 = b.x,
      y2 = b.y,
      r2 = b.r,
      x3 = c.x,
      y3 = c.y,
      r3 = c.r,
      a2 = x1 - x2,
      a3 = x1 - x3,
      b2 = y1 - y2,
      b3 = y1 - y3,
      c2 = r2 - r1,
      c3 = r3 - r1,
      d1 = x1 * x1 + y1 * y1 - r1 * r1,
      d2 = d1 - x2 * x2 - y2 * y2 + r2 * r2,
      d3 = d1 - x3 * x3 - y3 * y3 + r3 * r3,
      ab = a3 * b2 - a2 * b3,
      xa = (b2 * d3 - b3 * d2) / (ab * 2) - x1,
      xb = (b3 * c2 - b2 * c3) / ab,
      ya = (a3 * d2 - a2 * d3) / (ab * 2) - y1,
      yb = (a2 * c3 - a3 * c2) / ab,
      A = xb * xb + yb * yb - 1,
      B = 2 * (r1 + xa * xb + ya * yb),
      C = xa * xa + ya * ya - r1 * r1,
      r = -(A.abs() > 1e-6 ? (B + sqrt(B * B - 4 * A * C)) / (2 * A) : C / B);
  return PackCircle(x1 + xa + xb * r, y1 + ya + yb * r, r);
}

class PackCircle {
  double x;
  double y;
  double r;

  PackCircle(this.x, this.y, this.r);
}

void shuffle(List array, LCG random) {
  int m = array.length, i;
  while (m > 0) {
    i = (random.lcg() * m--).toInt() | 0;
    var t = array[m];
    array[m] = array[i];
    array[i] = t;
  }
}
