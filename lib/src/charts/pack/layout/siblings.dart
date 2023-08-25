import 'dart:core';
import 'dart:math' as m;
import '../../graph/layout/force/lcg.dart';
import 'enclose.dart';
import '../pack_node.dart';

class Siblings {

  static List<PackNode> siblings(List<PackNode> circles) {
    packSiblingsRandom(circles, DefaultLCG());
    return circles;
  }

  static void _place(InnerNode b, InnerNode a, InnerNode c) {
    num dx = b.x - a.x, x, a2, dy = b.y - a.y, y, b2, d2 = dx * dx + dy * dy;
    if (d2!=0) {
      a2 = a.r + c.r;
      a2 *= a2;
      b2 = b.r + c.r;
      b2 *= b2;
      if (a2 > b2) {
        x = (d2 + b2 - a2) / (2 * d2);
        y = m.sqrt(m.max(0, b2 / d2 - x * x));
        c.x = b.x - x * dx - y * dy;
        c.y = b.y - x * dy + y * dx;
      } else {
        x = (d2 + a2 - b2) / (2 * d2);
        y = m.sqrt(m.max(0, a2 / d2 - x * x));
        c.x = a.x + x * dx - y * dy;
        c.y = a.y + x * dy + y * dx;
      }
    } else {
      c.x = a.x + c.r;
      c.y = a.y;
    }
  }

  static bool _intersects(InnerNode a, InnerNode b) {
    var dr = a.r + b.r - 1e-6, dx = b.x - a.x, dy = b.y - a.y;
    return dr > 0 && dr * dr > dx * dx + dy * dy;
  }

  static num _score(InnerNode node) {
    PackProps a = node.circle, b = node.next!.circle;
    num ab = a.r + b.r, dx = (a.x * b.r + b.x * a.r) / ab, dy = (a.y * b.r + b.y * a.r) / ab;
    return dx * dx + dy * dy;
  }

  static num packSiblingsRandom(List<PackNode> circles, LCG random) {
    int n = circles.length;
    if (n == 0) return 0;

    InnerNode? a, b, c, j, k;
    int i;

    var aa, ca, sj, sk;

    // Place the first circle.
    a = InnerNode(circles[0].props);
    a.x = 0;
    a.y = 0;
    if (!(n > 1)) return a.r;

    // Place the second circle.
    b = InnerNode(circles[1].props);
    a.x = -b.r;
    b.x = a.r;
    b.y = 0;
    if (!(n > 2)) return a.r + b.r;

    // Place the third circle.
    _place(b, a, c = InnerNode(circles[2].props));

    // Initialize the front-chain using the first three circles a, b and c.
    a = InnerNode(a.circle);
    b = InnerNode(b.circle);
    c = InnerNode(c.circle);
    a.next = c.previous = b;
    b.next = a.previous = c;
    c.next = b.previous = a;

    // Attempt to place each remaining circle…
    pack:
    for (i = 3; i < n; ++i) {
      _place(a!, b!, c = InnerNode(circles[i].props));
      c = InnerNode(c.circle);

      j = b.next;
      k = a.previous;
      sj = b.r;
      sk = a.r;
      do {
        if (sj <= sk) {
          if (_intersects(j!, c)) {
            b = j;
            a!.next = b;
            b.previous = a;
            --i;
            continue pack;
          }
          sj += j.r;
          j = j.next;
        } else {
          if (_intersects(k!, c)) {
            a = k;
            a.next = b;
            b!.previous = a;
            --i;
            continue pack;
          }
          sk += k.r;
          k = k.previous;
        }
      } while (j != k?.next);

      // Success! Insert the new circle c between a and b.
      c.previous = a;
      c.next = b;
      a?.next = b?.previous = b = c;

      // Compute the new closest circle pair to the centroid.
      aa = _score(a!);
      while ((c = c?.next) != b) {
        if ((ca = _score(c!)) < aa) {
          a = c;
          aa = ca;
        }
      }
      b = a?.next;
    }

    // Compute the enclosing circle of the front chain.
    List<PackProps> cl = [b!.circle];
    c = b;
    while ((c = c?.next) != b) {
      cl.add(c!.circle);
    }
    c = InnerNode(packEncloseRandom(cl, random)!);

    // Translate the circles to put the enclosing circle around the origin.
    for (i = 0; i < n; ++i) {
      a = InnerNode(circles[i].props);
      a.x -= c.x;
      a.y -= c.y;
    }
    return c.r;
  }
}

class InnerNode {
  PackProps circle;
  InnerNode? next;
  InnerNode? previous;

  InnerNode(this.circle);

  double get x => circle.x;

  set x(num b) {
    circle.x = b.toDouble();
  }

  double get y => circle.y;

  set y(num b) {
    circle.y = b.toDouble();
  }

  double get r => circle.r.toDouble();

  set r(num v) => circle.r = r;
}
