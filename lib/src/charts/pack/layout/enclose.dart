import 'dart:math';

import 'package:flutter/material.dart';

import '../../graph/layout/force/lcg.dart';
import '../pack_node.dart';

PackProps? packEncloseRandom(List<PackProps> circles, LCG random) {
  shuffle(circles, random);
  int i = 0, n = circles.length;
  List<PackProps> B = [];
  PackProps p;
  PackProps? e;
  while (i < n) {
    p = circles[i];
    if (e != null && enclosesWeak(e, p)) {
      ++i;
    } else {
      e = encloseBasis(B = extendBasis(B, p));
      i = 0;
    }
  }
  return e;
}

List<PackProps> extendBasis(List<PackProps> B, PackProps p) {
  int i, j;
  if (enclosesWeakAll(p, B)) {
    return [p];
  }

  // If we get here then B must have at least one element.
  for (i = 0; i < B.length; ++i) {
    if (enclosesNot(p, B[i]) && enclosesWeakAll(encloseBasis2(B[i], p), B)) {
      return [B[i], p];
    }
  }

  // If we get here then B must have at least two elements.
  for (i = 0; i < B.length - 1; ++i) {
    for (j = i + 1; j < B.length; ++j) {
      if (enclosesNot(encloseBasis2(B[i], B[j]), p) &&
          enclosesNot(encloseBasis2(B[i], p), B[j]) &&
          enclosesNot(encloseBasis2(B[j], p), B[i]) &&
          enclosesWeakAll(encloseBasis3(B[i], B[j], p), B)) {
        return [B[i], B[j], p];
      }
    }
  }

  // If we get here then something is very wrong.
  throw FlutterError('异常');
}

bool enclosesNot(PackProps a, PackProps b) {
  var dr = a.r - b.r, dx = b.x - a.x, dy = b.y - a.y;
  return dr < 0 || dr * dr < dx * dx + dy * dy;
}

bool enclosesWeak(PackProps a, PackProps b) {
  num maxV = max(a.r, b.r);
  maxV = max(maxV, 1);
  var dr = a.r - b.r + maxV * 1e-9, dx = b.x - a.x, dy = b.y - a.y;
  return dr > 0 && dr * dr > dx * dx + dy * dy;
}

bool enclosesWeakAll(PackProps a, B) {
  for (var i = 0; i < B.length; ++i) {
    if (!enclosesWeak(a, B[i])) {
      return false;
    }
  }
  return true;
}

PackProps? encloseBasis(B) {
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

PackProps encloseBasis1(PackProps a) {
  return PackProps(a.x, a.y, a.r);
}

PackProps encloseBasis2(PackProps a, PackProps b) {
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

  PackProps data = PackProps(0,0,0);
  data.r = (l + r1 + r2) / 2;
  data.x=  (x1 + x2 + x21 / l * r21) / 2;
  data.y= (y1 + y2 + y21 / l * r21) / 2;
  return data;
}

PackProps encloseBasis3(PackProps a, PackProps b, PackProps c) {
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

  return PackProps(x1 + xa + xb * r, y1 + ya + yb * r, r);
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
