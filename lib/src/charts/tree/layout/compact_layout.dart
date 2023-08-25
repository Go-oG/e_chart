import 'dart:math';
import 'dart:core';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../node.dart';
import '../tree_layout.dart';

///紧凑树(不支持smooth)
class CompactLayout extends TreeLayout {
  Direction2 direction;
  Align2 levelAlign;

  CompactLayout({
    this.levelAlign = Align2.start,
    this.direction = Direction2.ttb,
    super.lineType = LineType.line,
    super.smooth = false,
    super.center = const [SNumber.percent(50), SNumber.percent(0)],
    super.centerIsRoot,
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
    super.levelGapSize,
    super.nodeGapSize,
    super.nodeSize,
  });

  @override
  void onLayout2(TreeLayoutNode root) {
    var l = _InnerLayout(root, direction: direction, levelGapFun: levelGapFun, gapFun: gapFun, levelAlign: levelAlign);
    l.layout(width, height);
  }
}

class _InnerLayout {
  late final TreeLayoutNode root;
  final Direction2 direction;
  final Align2 levelAlign;
  Fun3<TreeLayoutNode, TreeLayoutNode, Offset>? gapFun;
  Fun3<int, int, num>? levelGapFun;

  ///存储数据运算
  final List<double> _sizeOfLevel = [];
  final Map<TreeLayoutNode, num> _modMap = {};
  final Map<TreeLayoutNode, TreeLayoutNode> _threadMap = {};
  final Map<TreeLayoutNode, num> _prelimMap = {};
  final Map<TreeLayoutNode, num> _changeMap = {};
  final Map<TreeLayoutNode, num> _shiftMap = {};
  final Map<TreeLayoutNode, TreeLayoutNode> _ancestorMap = {};
  final Map<TreeLayoutNode, int> _numberMap = {};
  final Map<TreeLayoutNode, Point> _positionsMap = {};
  double _boundsLeft = _max;
  double _boundsRight = _min;
  double _boundsTop = _max;
  double _boundsBottom = _min;

  _InnerLayout(
    this.root, {
    this.direction = Direction2.ltr,
    this.levelAlign = Align2.start,
    this.levelGapFun,
    this.gapFun,
  });

  TreeLayoutNode layout(num width, num height) {
    _firstWalk(root, null);
    _calcSizeOfLevels(root, 0);
    _secondWalk(root, -_getPrelim(root), 0, 0);
    root.each((node, index, startNode) {
      Point point = _positionsMap[node]!;
      node.x = point.x - _boundsLeft;
      node.y = point.y - _boundsTop;
      return false;
    });
    return root;
  }

  double _getWidthOrHeightOfNode(TreeLayoutNode node, bool returnWidth) {
    Size size = node.size;
    return returnWidth ? size.width : size.height;
  }

  double _getNodeThickness(TreeLayoutNode treeNode) {
    return _getWidthOrHeightOfNode(treeNode, !_isLevelChangeInYAxis());
  }

  double _getNodeSize(TreeLayoutNode treeNode) {
    return _getWidthOrHeightOfNode(treeNode, _isLevelChangeInYAxis());
  }

  bool _isLevelChangeInYAxis() {
    return direction == Direction2.ttb || direction == Direction2.btt || direction == Direction2.v;
  }

  void _updateBounds(TreeLayoutNode node, num centerX, num centerY) {
    Size size = node.size;
    double width = size.width;
    double height = size.height;
    double left = centerX - width / 2;
    double right = centerX + width / 2;
    double top = centerY - height / 2;
    double bottom = centerY + height / 2;
    if (_boundsLeft > left) {
      _boundsLeft = left;
    }
    if (_boundsRight < right) {
      _boundsRight = right;
    }
    if (_boundsTop > top) {
      _boundsTop = top;
    }
    if (_boundsBottom < bottom) {
      _boundsBottom = bottom;
    }
  }

  Rectangle getBounds() {
    return Rectangle(0, 0, _boundsRight - _boundsLeft, _boundsBottom - _boundsTop);
  }

  void _calcSizeOfLevels(TreeLayoutNode node, int level) {
    double oldSize;
    if (_sizeOfLevel.length <= level) {
      _sizeOfLevel.add(0);
      oldSize = 0;
    } else {
      oldSize = _sizeOfLevel[level];
    }

    double size = _getNodeThickness(node);
    if (oldSize < size) {
      _sizeOfLevel[level] = size;
    }

    if (!node.isLeaf) {
      for (TreeLayoutNode child in node.children) {
        _calcSizeOfLevels(child, level + 1);
      }
    }
  }

  double getSizeOfLevel(int level) {
    if (level < 0) {
      throw FlutterError('level must be >= 0');
    }
    if (level >= _sizeOfLevel.length) {
      throw FlutterError('level must be < levelCount');
    }
    return _sizeOfLevel[level];
  }

  num _getMod(TreeLayoutNode? node) {
    return _modMap[node] ?? 0;
  }

  TreeLayoutNode? _nextLeft(TreeLayoutNode v) {
    return v.isLeaf ? _threadMap[v] : v.firstChild;
  }

  TreeLayoutNode? _nextRight(TreeLayoutNode v) {
    return v.isLeaf ? _threadMap[v] : v.lastChild;
  }

  int _getNumber(TreeLayoutNode node, TreeLayoutNode parentNode) {
    int? n = _numberMap[node];
    if (n == null) {
      int i = 1;
      for (TreeLayoutNode child in parentNode.children) {
        _numberMap[child] = i++;
      }
      n = _numberMap[node];
    }

    return n!;
  }

  TreeLayoutNode _ancestor(TreeLayoutNode vIMinus, TreeLayoutNode v, TreeLayoutNode parentOfV, TreeLayoutNode defaultAncestor) {
    TreeLayoutNode ancestor = (_ancestorMap[vIMinus] ?? vIMinus);
    return isChildOfParent(ancestor, parentOfV) ? ancestor : defaultAncestor;
  }

  bool isChildOfParent(TreeLayoutNode node, TreeLayoutNode parentNode) {
    return parentNode == node.parent;
  }

  void _moveSubtree(TreeLayoutNode wMinus, TreeLayoutNode wPlus, TreeLayoutNode parent, num shift) {
    int subtrees = _getNumber(wPlus, parent) - _getNumber(wMinus, parent);
    _changeMap[wPlus] = _getChange(wPlus) - shift / subtrees;
    _shiftMap[wPlus] = _getShift(wPlus) + shift;
    _changeMap[wMinus] = _getChange(wMinus) + shift / subtrees;
    _prelimMap[wPlus] = _getPrelim(wPlus) + shift;
    _modMap[wPlus] = _getMod(wPlus) + shift;
  }

  TreeLayoutNode _apportion(TreeLayoutNode v, TreeLayoutNode defaultAncestor, TreeLayoutNode? leftSibling, TreeLayoutNode parentOfV) {
    TreeLayoutNode? w = leftSibling;
    if (w == null) {
      return defaultAncestor;
    }
    TreeLayoutNode? vOPlus = v;
    TreeLayoutNode? vIPlus = v;
    TreeLayoutNode? vIMinus = w;
    TreeLayoutNode? vOMinus = parentOfV.firstChild;

    num sIPlus = _getMod(vIPlus);
    num sOPlus = _getMod(vOPlus);
    num sIMinus = _getMod(vIMinus);
    num sOMinus = _getMod(vOMinus);

    TreeLayoutNode? nextRightVIMinus = _nextRight(vIMinus);
    TreeLayoutNode? nextLeftVIPlus = _nextLeft(vIPlus);

    while (nextRightVIMinus != null && nextLeftVIPlus != null) {
      vIMinus = nextRightVIMinus;
      vIPlus = nextLeftVIPlus;
      vOMinus = _nextLeft(vOMinus!);
      vOPlus = _nextRight(vOPlus!);
      _ancestorMap[vOPlus!] = v;
      num shift = (_getPrelim(vIMinus) + sIMinus) - (_getPrelim(vIPlus) + sIPlus) + _getDistance(vIMinus, vIPlus);

      if (shift > 0) {
        _moveSubtree(_ancestor(vIMinus, v, parentOfV, defaultAncestor), v, parentOfV, shift);
        sIPlus = sIPlus + shift;
        sOPlus = sOPlus + shift;
      }
      sIMinus = sIMinus + _getMod(vIMinus);
      sIPlus = sIPlus + _getMod(vIPlus);
      sOMinus = sOMinus + _getMod(vOMinus);
      sOPlus = sOPlus + _getMod(vOPlus);

      nextRightVIMinus = _nextRight(vIMinus);
      nextLeftVIPlus = _nextLeft(vIPlus);
    }

    if (nextRightVIMinus != null && _nextRight(vOPlus!) == null) {
      _threadMap[vOPlus] = nextRightVIMinus;
      _modMap[vOPlus] = _getMod(vOPlus) + sIMinus - sOPlus;
    }

    if (nextLeftVIPlus != null && _nextLeft(vOMinus!) == null) {
      _threadMap[vOMinus] = nextLeftVIPlus;
      _modMap[vOMinus] = _getMod(vOMinus) + sIPlus - sOMinus;
      defaultAncestor = v;
    }
    return defaultAncestor;
  }

  void _executeShifts(TreeLayoutNode v) {
    num shift = 0;
    num change = 0;
    for (TreeLayoutNode w in v.childrenReverse) {
      change = change + _getChange(w);
      _prelimMap[w] = _getPrelim(w) + shift;
      _modMap[w] = _getMod(w) + shift;
      shift = shift + _getShift(w) + change;
    }
  }

  void _firstWalk(TreeLayoutNode v, TreeLayoutNode? leftSibling) {
    if (v.isLeaf) {
      TreeLayoutNode? w = leftSibling;
      if (w != null) {
        _prelimMap[v] = _getPrelim(w) + _getDistance(v, w);
      }
    } else {
      TreeLayoutNode defaultAncestor = v.firstChild;
      TreeLayoutNode? previousChild;
      for (TreeLayoutNode w in v.children) {
        _firstWalk(w, previousChild);
        defaultAncestor = _apportion(w, defaultAncestor, previousChild, v);
        previousChild = w;
      }
      _executeShifts(v);
      num midpoint = (_getPrelim(v.firstChild) + _getPrelim(v.lastChild)) / 2.0;
      TreeLayoutNode? w = leftSibling;
      if (w != null) {
        _prelimMap[v] = _getPrelim(w) + _getDistance(v, w);
        _modMap[v] = _getPrelim(v) - midpoint;
      } else {
        _prelimMap[v] = midpoint;
      }
    }
  }

  void _secondWalk(TreeLayoutNode v, num m, int level, num levelStart) {
    int levelChangeSign = (direction == Direction2.btt || direction == Direction2.rtl) ? -1 : 1;
    bool levelChangeOnYAxis = _isLevelChangeInYAxis();
    num levelSize = getSizeOfLevel(level);
    num x = _getPrelim(v) + m;
    num y;
    if (levelAlign == Align2.center) {
      y = levelStart + levelChangeSign * (levelSize / 2);
    } else if (levelAlign == Align2.start) {
      y = levelStart + levelChangeSign * (_getNodeThickness(v) / 2);
    } else {
      y = levelStart + levelSize - levelChangeSign * (_getNodeThickness(v) / 2);
    }
    if (!levelChangeOnYAxis) {
      num t = x;
      x = y;
      y = t;
    }
    _positionsMap[v] = Point(x, y);
    _updateBounds(v, x, y);
    if (!v.isLeaf) {
      num nextLevelStart = levelStart + (levelSize + _levelGap(level, level + 1)) * levelChangeSign;
      for (TreeLayoutNode w in v.children) {
        _secondWalk(w, m + _getMod(v), level + 1, nextLevelStart);
      }
    }
  }

  void _addUniqueNodes(Map<TreeLayoutNode, TreeLayoutNode> nodes, TreeLayoutNode newNode) {
    TreeLayoutNode? old = nodes[newNode];
    if (old != null) {
      throw FlutterError("Node used more than once in tree: %s");
    }
    nodes[newNode] = newNode;
    for (TreeLayoutNode n in newNode.children) {
      _addUniqueNodes(nodes, n);
    }
  }

  void checkTree() {
    Map<TreeLayoutNode, TreeLayoutNode> nodes = {};
    _addUniqueNodes(nodes, root);
  }

  num _getPrelim(TreeLayoutNode? node) {
    return _prelimMap[node] ?? 0;
  }

  num _getChange(TreeLayoutNode? node) {
    return _changeMap[node] ?? 0;
  }

  num _getShift(TreeLayoutNode? node) {
    return _shiftMap[node] ?? 0;
  }

  num _getDistance(TreeLayoutNode v, TreeLayoutNode w) {
    double sizeOfNodes = _getNodeSize(v) + _getNodeSize(w);
    num distance = sizeOfNodes / 2 + _nodeGap(v, w);
    return distance;
  }

  num _levelGap(int index1, int index2) {
    if (levelGapFun != null) {
      return levelGapFun!.call(index1, index2);
    }
    return 16;
  }

  num _nodeGap(TreeLayoutNode v, TreeLayoutNode w) {
    if (gapFun != null) {
      Offset gap = gapFun!.call(v, w);
      if (direction == Direction2.rtl || direction == Direction2.ltr) {
        return gap.dy;
      }
      return gap.dx;
    }
    return 2;
  }
}

const double _max = 1.7e10;
const double _min = -1 * 1.7e10;
