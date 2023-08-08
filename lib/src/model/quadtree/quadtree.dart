import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'quad_node.dart';

class QuadTree<T> {
  QuadNode<T>? _root;

  //用于返回指定数据的X坐标和Y坐标
  OffsetFun<T> xFun;
  OffsetFun<T> yFun;

  ///表示区域范围
  num _x0;
  num _y0;
  num _x1;
  num _y1;

  QuadTree(this.xFun, this.yFun, this._x0, this._y0, this._x1, this._y1) {
    _root = null;
  }

  static QuadTree<T> simple<T>(OffsetFun<T> xFun, OffsetFun<T> yFun, List<T> nodes) {
    QuadTree<T> tree = QuadTree(xFun, yFun, double.nan, double.nan, double.nan, double.nan);
    if (nodes.isNotEmpty) {
      tree.addAll(nodes);
    }
    return tree;
  }

  QuadNode<T> leafCopy(QuadNode<T> leaf) {
    QuadNode<T> copy = QuadNode(data: leaf.data);
    QuadNode<T>? next = copy;

    QuadNode<T>? leftTmp = leaf;
    while ((leftTmp = leftTmp?.next) != null) {
      next!.next = QuadNode(data: leftTmp!.data);
      next = next.next;
    }
    return copy;
  }

  QuadTree<T> addAll(List<T> data) {
    int n = data.length;
    Float64List xz = Float64List(n);
    Float64List yz = Float64List(n);
    double x0 = double.infinity;
    double y0 = x0;
    double x1 = -x0;
    double y1 = x1;

    // 计算点及其范围
    T d;
    double x, y;
    for (int i = 0; i < n; ++i) {
      d = data[i];
      x = xFun.call(d);
      y = yFun.call(d);
      if (x.isNaN || y.isNaN) {
        continue;
      }
      xz[i] = x;
      yz[i] = y;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }

    // 如果没有（有效）点，则中止
    if (x0 > x1 || y0 > y1) {
      return this;
    }

    // 拓展树范围以覆盖新点
    cover(x0, y0).cover(x1, y1);

    // 添加新的点.
    for (int i = 0; i < n; ++i) {
      _addInner(this, xz[i], yz[i], data[i]);
    }
    return this;
  }

  QuadTree add(T data) {
    num x = xFun.call(data);
    num y = yFun.call(data);
    return _addInner(cover(x, y), x, y, data);
  }

  QuadTree<T> _addInner(QuadTree<T> tree, num x, num y, T data) {
    if (x.isNaN || y.isNaN) {
      return tree;
    }

    QuadNode<T> leaf = QuadNode<T>(data: data);
    // If the tree is empty, initialize the root as a leaf.
    if (tree._root == null) {
      tree._root = leaf;
      return tree;
    }

    num x0 = tree._x0, y0 = tree._y0, x1 = tree._x1, y1 = tree._y1;

    QuadNode<T>? parent;
    QuadNode<T>? node = tree._root!;
    num xm, ym;
    num xp;
    num yp;
    int right;
    int bottom;
    int i = 0;
    int j = 0;

    // Find the existing leaf for the new point, or add it.
    while (node!.hasChild) {
      if ((right = _toInt(x >= (xm = ((x0 + x1) / 2)))) != 0) {
        x0 = xm;
      } else {
        x1 = xm;
      }
      if ((bottom = _toInt(y >= (ym = ((y0 + y1) / 2)))) != 0) {
        y0 = ym;
      } else {
        y1 = ym;
      }
      parent = node;

      if ((node = node[i = bottom << 1 | right]) == null) {
        parent[i] = leaf;
        return tree;
      }
    }

    // 新的点和存在的点完全重合
    xp = xFun.call(node.data as T);
    yp = yFun.call(node.data as T);

    if (x == xp && y == yp) {
      leaf.next = node;
      if (parent != null) {
        parent[i] = leaf;
      } else {
        tree._root = leaf;
      }
      return tree;
    }

    //否则，拆分叶节点，直到新旧点分离
    do {
      if (parent != null) {
        parent = parent[i] = QuadNode(length: 4);
      } else {
        parent = tree._root = QuadNode(length: 4);
      }
      if ((right = _toInt(x >= (xm = ((x0 + x1) / 2)))) != 0) {
        x0 = xm;
      } else {
        x1 = xm;
      }
      if ((bottom = _toInt(y >= (ym = ((y0 + y1) / 2)))) != 0) {
        y0 = ym;
      } else {
        y1 = ym;
      }
    } while ((i = bottom << 1 | right) == (j = (_toInt(yp >= ym) << 1 | _toInt(xp >= xm))));

    parent[j] = node;
    parent[i] = leaf;
    return tree;
  }

  QuadTree<T> cover(num x, num y) {
    if (x.isNaN || y.isNaN) {
      return this;
    }
    num x0 = _x0, y0 = _y0, x1 = _x1, y1 = _y1;
    if (x0.isNaN) {
      x1 = (x0 = x.floor()) + 1;
      y1 = (y0 = y.floor()) + 1;
    } else {
      // 否则，重复覆盖
      num z = (x1 - x0) == 0 ? 1 : (x1 - x0);
      QuadNode<T>? node = _root;
      QuadNode<T>? parent;
      int i;
      while (x0 > x || x >= x1 || y0 > y || y >= y1) {
        i = _toInt(y < y0) << 1 | _toInt(x < x0);
        parent = QuadNode(length: 4);
        parent[i] = node;
        node = parent;
        z *= 2;

        switch (i) {
          case 0:
            x1 = x0 + z;
            y1 = y0 + z;
            break;
          case 1:
            x0 = x1 - z;
            y1 = y0 + z;
            break;
          case 2:
            x1 = x0 + z;
            y0 = y1 - z;
            break;
          case 3:
            x0 = x1 - z;
            y0 = y1 - z;
            break;
        }
      }
      if (_root != null && _root!.hasChild) {
        _root = node;
      }
    }

    _x0 = x0;
    _y0 = y0;
    _x1 = x1;
    _y1 = y1;
    return this;
  }

  List<T> get data {
    List<T> list = [];
    each((node, x0, y0, x1, y1) {
      QuadNode? nodeTmp = node;
      if (!nodeTmp.hasChild) {
        do {
          list.add(nodeTmp!.data!);
        } while ((nodeTmp = nodeTmp.next) != null);
      }
      return true;
    });
    return list;
  }

  /// 拓展四叉树范围
  /// 如果指定了area，则扩展四叉树以覆盖到指定的点[[x0, y0], [x1, y1]] 并返回四叉树。
  /// 如果没有指定position，则返回四叉树当前的范围[[x0, y0], [x1, y1]]，
  QuadTree<T> extent(Rect rect) {
    Offset p0 = rect.topLeft;
    Offset p1 = rect.bottomRight;
    cover(p0.dx, p0.dy).cover(p1.dx, p1.dy);
    return this;
  }

  Rect get boundRect => Rect.fromLTRB(_x0.toDouble(), _y0.toDouble(), _x1.toDouble(), _y1.toDouble());

  ///返回离给定搜索半径的位置⟨x,y⟩最近的点。
  ///如果没有指定半径，默认为无穷大。
  ///如果在搜索范围内没有基准点，则返回未定义
  T? find(int x, int y, [double? r]) {
    T? data;
    num x0 = _x0;
    num y0 = _y0;
    num x1 = 0, y1 = 0, x2 = 0, y2 = 0;
    num x3 = _x1;
    num y3 = _y1;
    List<InnerQuad> quads = [];

    QuadNode? node = _root;
    int i = 0;
    if (node != null) {
      quads.add(InnerQuad(node, x0, y0, x3, y3));
    }

    double radius;
    if (r == null) {
      radius = double.infinity;
    } else {
      x0 = (x - r);
      y0 = (y - r);
      x3 = (x + r);
      y3 = (y + r);
      radius = r * r;
    }

    while (quads.isNotEmpty) {
      InnerQuad q = quads.removeLast();
      // 如果此象限不能包含更近的节点，请停止搜索
      node = q.node;
      if (node == null || (x1 = q.x0) > x3 || (y1 = q.y0) > y3 || (x2 = q.x1) < x0 || (y2 = q.y1) < y0) {
        continue;
      }
      //将当前象限一分为二.
      if (node.hasChild) {
        int xm = ((x1 + x2) / 2).round(), ym = ((y1 + y2) / 2).round();
        if (node[3] != null) {
          quads.add(InnerQuad(node[3]!, xm, ym, x2, y2));
        }
        if (node[2] != null) {
          quads.add(InnerQuad(node[2]!, x1, ym, xm, y2));
        }
        if (node[1] != null) {
          quads.add(InnerQuad(node[1]!, xm, y1, x2, ym));
        }
        if (node[0] != null) {
          quads.add(InnerQuad(node[0]!, x1, y1, xm, ym));
        }

        //首先访问最近的象限
        if ((i = _toInt(y >= ym) << 1 | _toInt(x >= xm)) != 0) {
          q = quads[quads.length - 1];
          quads[quads.length - 1] = quads[quads.length - 1 - i];
          quads[quads.length - 1 - i] = q;
        }
      } else {
        // 访问此点（不需要访问重合点！）
        var dx = x - xFun(node.data), dy = y - yFun(node.data);
        double d2 = (dx * dx + dy * dy);
        if (d2 < radius) {
          radius = d2;
          var d = sqrt(radius);
          x0 = x - d;
          y0 = y - d;
          x3 = x + d;
          y3 = y + d;
          data = node.data!;
        }
      }
    }
    return data;
  }

  QuadTree<T> remove(T d) {
    num pointX = xFun.call(d), pointY = yFun.call(d);

    if (pointX.isNaN || pointX.isNaN) {
      return this;
    }

    QuadNode<T>? parent;
    QuadNode<T>? node = _root;
    QuadNode<T>? retainer;
    QuadNode<T>? previous;
    QuadNode<T>? next;
    num x0 = _x0;
    num y0 = _y0;
    num x1 = _x1;
    num y1 = _y1;
    int xm = 0, ym = 0;
    int right = 0, bottom = 0;
    int i = 0;
    int j = 0;
    // 如果树为空则将叶子节点初始化为根节点
    if (node == null) {
      return this;
    }
    //查找该点的叶节点。
    //当下降时，还保留最深的父级和未删除的同级
    if (node.hasChild) {
      while (true) {
        int a = xm = ((x0 + x1) / 2).round();
        int b = ym = ((y0 + y1) / 2).round();
        if ((right = _toInt(pointX >= a)) != 0) {
          x0 = xm;
        } else {
          x1 = xm;
        }
        if ((bottom = _toInt(pointY >= b)) != 0) {
          y0 = ym;
        } else {
          y1 = ym;
        }
        parent = node;
        if ((node = node![i = bottom << 1 | right]) == null) {
          return this;
        }
        if (!node!.hasChild) {
          break;
        }
        if ((parent![(i + 1) & 3]) != null || (parent[(i + 2) & 3]) != null || (parent[(i + 3) & 3]) != null) {
          retainer = parent;
          j = i;
        }
      }
    }

    // Find the point to remove.
    while (node!.data != d) {
      previous = node;
      node = node.next;
      if (node == null) {
        return this;
      }
    }

    if ((next = node.next) != null) {
      node.next = null;
    }

    // If there are multiple coincident points, remove just the point.
    if (previous != null) {
      previous.next = next;
      return this;
    }

    // If this is the root point, remove it.
    if (parent == null) {
      _root = next;
      return this;
    }
    // Remove this leaf.
    parent[i] = next;

    // If the parent now contains exactly one leaf, collapse superfluous parents.
    QuadNode<T>? tmpNode = parent[0];
    tmpNode ??= parent[1];
    tmpNode ??= parent[2];
    tmpNode ??= parent[3];

    QuadNode<T>? tmpNode2 = parent[3];
    tmpNode2 ??= parent[2];
    tmpNode2 ??= parent[1];
    tmpNode2 ??= parent[0];

    if ((node = tmpNode) != null && node == tmpNode2 && !node!.hasChild) {
      if (retainer != null) {
        retainer[j] = node;
      } else {
        _root = node;
      }
    }
    return this;
  }

  QuadTree<T> removeAll(List<T> data) {
    for (var i = 0, n = data.length; i < n; ++i) {
      remove(data[i]);
    }
    return this;
  }

  QuadTree<T> each(VisitCallback<T> callback) {
    List<InnerQuad<T>> quads = [];
    QuadNode<T>? node = _root;
    QuadNode<T>? child;
    num x0;
    num y0;
    num x1;
    num y1;

    if (node != null) {
      quads.add(InnerQuad(node, _x0, _y0, _x1, _y1));
    }

    while (quads.isNotEmpty) {
      InnerQuad<T> q = quads.removeLast();
      node = q.node;
      if (!callback.call(node, x0 = q.x0, y0 = q.y0, x1 = q.x1, y1 = q.y1) && node.hasChild) {
        int xm = ((x0 + x1) / 2).round(), ym = ((y0 + y1) / 2).round();
        if ((child = node[3]) != null) quads.add(InnerQuad(child!, xm, ym, x1, y1));
        if ((child = node[2]) != null) quads.add(InnerQuad(child!, x0, ym, xm, y1));
        if ((child = node[1]) != null) quads.add(InnerQuad(child!, xm, y0, x1, ym));
        if ((child = node[0]) != null) quads.add(InnerQuad(child!, x0, y0, xm, ym));
      }
    }
    return this;
  }

  QuadTree<T> eachAfter(VisitCallback<T> callback) {
    List<InnerQuad<T>> quads = [];
    List<InnerQuad<T>> next = [];
    InnerQuad<T> q;
    if (_root != null) {
      quads.add(InnerQuad(_root!, _x0, _y0, _x1, _y1));
    }

    while (quads.isNotEmpty) {
      q = quads.removeLast();
      QuadNode<T>? node = q.node;
      if (node.hasChild) {
        num x0 = q.x0, y0 = q.y0, x1 = q.x1, y1 = q.y1;
        num xm = ((x0 + x1) / 2);
        num ym = ((y0 + y1) / 2);
        QuadNode<T>? child;
        if ((child = node[0]) != null) quads.add(InnerQuad(child!, x0, y0, xm, ym));
        if ((child = node[1]) != null) quads.add(InnerQuad(child!, xm, y0, x1, ym));
        if ((child = node[2]) != null) quads.add(InnerQuad(child!, x0, ym, xm, y1));
        if ((child = node[3]) != null) quads.add(InnerQuad(child!, xm, ym, x1, y1));
      }
      next.add(q);
    }

    while (next.isNotEmpty) {
      q = next.removeLast();
      callback(q.node, q.x0, q.y0, q.x1, q.y1);
    }
    return this;
  }

  QuadTree<T> copy() {
    QuadTree<T> copy = QuadTree(xFun, yFun, _x0, _y0, _x1, _y1);
    QuadNode<T>? node = _root;

    List<Map<String, dynamic>> nodes = [];
    QuadNode<T>? child;

    if (node == null) {
      return copy;
    }

    if (!node.hasChild) {
      copy._root = leafCopy(node);
      return copy;
    }

    copy._root = QuadNode(length: 4);
    nodes = [
      {'source': node, 'target': copy._root}
    ];

    Map<String, dynamic> nodeTmp;
    while (nodes.isNotEmpty) {
      nodeTmp = nodes.removeLast();
      for (int i = 0; i < 4; ++i) {
        child = nodeTmp['source'][i];
        if (child == null) {
          continue;
        }
        if (child.hasChild) {
          var tmp = {'source': child, 'target': nodeTmp['target'][i] = QuadNode(length: 4)};
          nodes.add(tmp);
        } else {
          nodeTmp['target'][i] = leafCopy(child);
        }
      }
    }
    return copy;
  }

  QuadNode? get root => _root;

  int get size {
    int sizeTmp = 0;
    each((node, p1, p2, p3, p4) {
      QuadNode? nodeTmp = node;
      if (nodeTmp.hasChild) {
        do {
          ++sizeTmp;
        } while ((nodeTmp = nodeTmp!.next) != null);
      }
      return true;
    });
    return sizeTmp;
  }

  @override
  String toString() {
    return 'x0:$_x0 y0:$_y0 x1:$_x1 y1:$_y1';
  }
}

///将一个bool值转换为int
int _toInt(bool a) {
  return a ? 1 : 0;
}

/// 内部临时节点
class InnerQuad<T> {
  final QuadNode<T> node;
  final num x0;
  final num y0;
  final num x1;
  final num y1;

  InnerQuad(this.node, this.x0, this.y0, this.x1, this.y1);
}

typedef VisitCallback<T> = bool Function(QuadNode<T> node, num left, num top, num right, num bottom);

typedef OffsetFun<T> = double Function(T data);
