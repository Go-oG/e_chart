import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class D3TreeLayout extends TreeLayout {
  ///分离函数，用于决定两个节点(一般为兄弟节点)之间的间距
  Fun3<TreeLayoutNode, TreeLayoutNode, num> splitFun = (a, b) {
    ///对于Radial布局 一般设置为 (a.parent == b.parent ? 1 : 2) / a.depth;
    return a.parent == b.parent ? 1 : 2;
  };

  /// 当该参数为true时，表示[onLayout]方法中的传入的参数为每层之间的间距
  /// 为false时则表示映射到给定的布局参数
  bool diff = false;

  D3TreeLayout({
    this.diff = false,
    super.gapFun,
    super.levelGapFun,
    super.lineType,
    super.sizeFun,
    super.center = const [SNumber.percent(50), SNumber.percent(0)],
    super.centerIsRoot,
    super.levelGapSize,
    super.nodeGapSize,
    super.nodeSize,
  });

  @override
  void onLayout2(TreeLayoutNode root) {
    num dx = width;
    num dy = height;
    InnerNode t = _treeRoot(root);
    t.eachAfter(_firstWalk);
    t.parent!.m = -t.z;
    t.eachBefore(_secondWalk);

    if (diff) {
      root.eachBefore((node, b, c) {
        _sizeNode(node, dx, dy);
        return false;
      });
    } else {
      var left = root, right = root, bottom = root;

      ///找到最右 最左 最低的节点
      root.eachBefore((node, b, c) {
        if (node.x < left.x) left = node;
        if (node.x > right.x) right = node;
        if (node.deep > bottom.deep) bottom = node;
        return false;
      });

      var split = left == right ? 1 : splitFun.call(left, right) / 2;

      var tx = split - left.x, kx = dx / (right.x + split + tx), ky = dy / (jsOr(bottom.deep, 1));
      root.eachBefore((node, b, c) {
        node.x = (node.x + tx) * kx;
        node.y = node.deep * ky;
        return false;
      });
    }
  }

  void _moveSubtree(InnerNode wm, InnerNode wp, num shift) {
    var change = shift / (wp.i - wm.i);
    wp.c -= change;
    wp.s += shift;
    wm.c += change;
    wp.z += shift;
    wp.m += shift;
  }

  void _executeShifts(InnerNode v) {
    num shift = 0.0;
    num change = 0;
    var children = v.children;
    int i = children.length;
    InnerNode w;
    while (--i >= 0) {
      w = children[i];
      w.z += shift;
      w.m += shift;
      shift += w.s + (change += w.c);
    }
  }

  InnerNode _nextAncestor(InnerNode vim, InnerNode v, InnerNode ancestor) {
    return vim.a!.parent == v.parent ? vim.a! : ancestor;
  }

  InnerNode _treeRoot(TreeLayoutNode root) {
    InnerNode tree = InnerNode(null, root, 0);
    List<InnerNode> nodes = [tree];
    List<TreeLayoutNode> children = [];
    while (nodes.isNotEmpty) {
      var node = nodes.removeLast();
      children = node.node!.children;
      if (children.isNotEmpty) {
        node.children.addAll(List.generate(children.length, (index) => InnerNode(null, null, 0)));
        for (int i = children.length - 1; i >= 0; --i) {
          var child = node.children[i] = InnerNode(null, children[i], i);
          nodes.add(child);
          child.parent = node;
        }
      }
    }
    var p = InnerNode(null, null, 0);
    tree.parent = p;
    p.children.add(tree);
    return tree;
  }

  bool _firstWalk(InnerNode v, b, c) {
    List<InnerNode> children = v.children;
    var siblings = v.parent!.children;
    InnerNode? w = isTrue(v.i) ? siblings[v.i - 1] : null;
    if (children.isNotEmpty) {
      _executeShifts(v);
      var midpoint = (children[0].z + children[children.length - 1].z) / 2;
      if (w != null) {
        v.z = w.z + splitFun.call(v.node!, w.node!);
        v.m = v.z - midpoint;
      } else {
        v.z = midpoint;
      }
    } else if (w != null) {
      v.z = w.z + splitFun.call(v.node!, w.node!);
    }
    v.parent?.A = _apportion(v, w, jsOr(v.parent?.A, siblings[0]));
    return false;
  }

  bool _secondWalk(InnerNode v, b, c) {
    v.node!.x = v.z + v.parent!.m;
    v.m += v.parent!.m;
    return false;
  }

  InnerNode _apportion(InnerNode v, InnerNode? w, InnerNode ancestor) {
    if (w != null) {
      InnerNode? vip = v;
      InnerNode vop = v;
      InnerNode? vim = w;
      InnerNode vom = vip.parent!.children[0];
      num sip = vip.m;
      num sop = vop.m;
      num sim = vim.m;
      num som = vom.m;
      num shift;
      while (true) {
        vim = _nextRight(vim!);
        vip = _nextLeft(vip!);
        if (!jsAnd2(vim, vip)) {
          break;
        }

        vom = _nextLeft(vom)!;
        vop = _nextRight(vop)!;
        vop.a = v;
        shift = vim!.z + sim - vip!.z - sip + splitFun.call(vim.node!, vip.node!);
        if (shift > 0) {
          _moveSubtree(_nextAncestor(vim, v, ancestor), v, shift);
          sip += shift;
          sop += shift;
        }
        sim += vim.m;
        sip += vip.m;
        som += vom.m;
        sop += vop.m;
      }
      if (isTrue(vim) && !isTrue(_nextRight(vop))) {
        vop.t = vim!;
        vop.m += sim - sop;
      }
      if (isTrue(vip) && !isTrue(_nextLeft(vom))) {
        vom.t = vip!;
        vom.m += sip - som;
        ancestor = v;
      }
    }
    return ancestor;
  }

  void _sizeNode(TreeLayoutNode node, num dx, num dy) {
    node.x *= dx;
    node.y = node.deep * dy;
  }

  InnerNode? _nextLeft(InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[0] : v.t;
  }

  InnerNode? _nextRight(InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[children.length - 1] : v.t;
  }
}

class InnerNode extends TreeNode<Offset, Offset, InnerNode> {
  TreeLayoutNode? node;
  int i;
  InnerNode? A; // default ancestor
  InnerNode? a; // ancestor
  num z = 0; // prelim
  num m = 0; // mod
  num c = 0; // change
  num s = 0; // shift
  InnerNode? t; // thread
  num x = 0;
  num y = 0;

  InnerNode(
    InnerNode? parent,
    this.node,
    this.i,
  ) : super(parent, Offset.zero, 0, Offset.zero, AreaStyle.empty, LineStyle.empty, LabelStyle.empty) {
    a = this;
  }

  @override
  bool contains(Offset offset) => false;

  @override
  void onDraw(CCanvas canvas, Paint paint) {}

  @override
  void updateStyle(Context context, covariant ChartSeries series) {
  }
}
