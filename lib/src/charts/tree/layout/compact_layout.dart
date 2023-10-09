import 'dart:math';
import 'dart:core';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///紧凑树(不支持smooth)
class CompactLayout extends TreeLayout {
  Direction2 direction;
  Align2 levelAlign;

  CompactLayout({
    this.levelAlign = Align2.start,
    this.direction = Direction2.ttb,
    super.lineType = LineType.line,
    super.smooth = 0,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void onLayout(TreeRenderNode rootNode, TreeLayoutParams params) {
    var l = _InnerLayout(rootNode, direction: direction, levelGapFun: levelGapFun, gapFun: gapFun, levelAlign: levelAlign);
    l.layout(params.width, params.height);
  }
}

class _InnerLayout {
  late final TreeRenderNode root;
  final Direction2 direction;
  final Align2 levelAlign;
  Fun3<TreeRenderNode, TreeRenderNode, Offset>? gapFun;
  Fun3<int, int, num>? levelGapFun;

  ///存储数据运算
  final List<double> _sizeOfLevel = [];
  final Map<TreeRenderNode, num> _modMap = {};
  final Map<TreeRenderNode, TreeRenderNode> _threadMap = {};
  final Map<TreeRenderNode, num> _prelimMap = {};
  final Map<TreeRenderNode, num> _changeMap = {};
  final Map<TreeRenderNode, num> _shiftMap = {};
  final Map<TreeRenderNode, TreeRenderNode> _ancestorMap = {};
  final Map<TreeRenderNode, int> _numberMap = {};
  final Map<TreeRenderNode, Point> _positionsMap = {};
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

  TreeRenderNode layout(num width, num height) {
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

  double _getWidthOrHeightOfNode(TreeRenderNode node, bool returnWidth) {
    Size size = node.size;
    return returnWidth ? size.width : size.height;
  }

  double _getNodeThickness(TreeRenderNode treeNode) {
    return _getWidthOrHeightOfNode(treeNode, !_isLevelChangeInYAxis());
  }

  double _getNodeSize(TreeRenderNode treeNode) {
    return _getWidthOrHeightOfNode(treeNode, _isLevelChangeInYAxis());
  }

  bool _isLevelChangeInYAxis() {
    return direction == Direction2.ttb || direction == Direction2.btt || direction == Direction2.v;
  }

  void _updateBounds(TreeRenderNode node, num centerX, num centerY) {
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

  void _calcSizeOfLevels(TreeRenderNode node, int level) {
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
      for (TreeRenderNode child in node.children) {
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

  num _getMod(TreeRenderNode? node) {
    return _modMap[node] ?? 0;
  }

  TreeRenderNode? _nextLeft(TreeRenderNode v) {
    return v.isLeaf ? _threadMap[v] : v.firstChild;
  }

  TreeRenderNode? _nextRight(TreeRenderNode v) {
    return v.isLeaf ? _threadMap[v] : v.lastChild;
  }

  int _getNumber(TreeRenderNode node, TreeRenderNode parentNode) {
    int? n = _numberMap[node];
    if (n == null) {
      int i = 1;
      for (TreeRenderNode child in parentNode.children) {
        _numberMap[child] = i++;
      }
      n = _numberMap[node];
    }

    return n!;
  }

  TreeRenderNode _ancestor(TreeRenderNode vIMinus, TreeRenderNode v, TreeRenderNode parentOfV, TreeRenderNode defaultAncestor) {
    TreeRenderNode ancestor = (_ancestorMap[vIMinus] ?? vIMinus);
    return isChildOfParent(ancestor, parentOfV) ? ancestor : defaultAncestor;
  }

  bool isChildOfParent(TreeRenderNode node, TreeRenderNode parentNode) {
    return parentNode == node.parent;
  }

  void _moveSubtree(TreeRenderNode wMinus, TreeRenderNode wPlus, TreeRenderNode parent, num shift) {
    int subtrees = _getNumber(wPlus, parent) - _getNumber(wMinus, parent);
    _changeMap[wPlus] = _getChange(wPlus) - shift / subtrees;
    _shiftMap[wPlus] = _getShift(wPlus) + shift;
    _changeMap[wMinus] = _getChange(wMinus) + shift / subtrees;
    _prelimMap[wPlus] = _getPrelim(wPlus) + shift;
    _modMap[wPlus] = _getMod(wPlus) + shift;
  }

  TreeRenderNode _apportion(TreeRenderNode v, TreeRenderNode defaultAncestor, TreeRenderNode? leftSibling, TreeRenderNode parentOfV) {
    TreeRenderNode? w = leftSibling;
    if (w == null) {
      return defaultAncestor;
    }
    TreeRenderNode? vOPlus = v;
    TreeRenderNode? vIPlus = v;
    TreeRenderNode? vIMinus = w;
    TreeRenderNode? vOMinus = parentOfV.firstChild;

    num sIPlus = _getMod(vIPlus);
    num sOPlus = _getMod(vOPlus);
    num sIMinus = _getMod(vIMinus);
    num sOMinus = _getMod(vOMinus);

    TreeRenderNode? nextRightVIMinus = _nextRight(vIMinus);
    TreeRenderNode? nextLeftVIPlus = _nextLeft(vIPlus);

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

  void _executeShifts(TreeRenderNode v) {
    num shift = 0;
    num change = 0;
    for (TreeRenderNode w in v.childrenReverse) {
      change = change + _getChange(w);
      _prelimMap[w] = _getPrelim(w) + shift;
      _modMap[w] = _getMod(w) + shift;
      shift = shift + _getShift(w) + change;
    }
  }

  void _firstWalk(TreeRenderNode v, TreeRenderNode? leftSibling) {
    if (v.isLeaf) {
      TreeRenderNode? w = leftSibling;
      if (w != null) {
        _prelimMap[v] = _getPrelim(w) + _getDistance(v, w);
      }
    } else {
      TreeRenderNode defaultAncestor = v.firstChild;
      TreeRenderNode? previousChild;
      for (TreeRenderNode w in v.children) {
        _firstWalk(w, previousChild);
        defaultAncestor = _apportion(w, defaultAncestor, previousChild, v);
        previousChild = w;
      }
      _executeShifts(v);
      num midpoint = (_getPrelim(v.firstChild) + _getPrelim(v.lastChild)) / 2.0;
      TreeRenderNode? w = leftSibling;
      if (w != null) {
        _prelimMap[v] = _getPrelim(w) + _getDistance(v, w);
        _modMap[v] = _getPrelim(v) - midpoint;
      } else {
        _prelimMap[v] = midpoint;
      }
    }
  }

  void _secondWalk(TreeRenderNode v, num m, int level, num levelStart) {
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
      for (TreeRenderNode w in v.children) {
        _secondWalk(w, m + _getMod(v), level + 1, nextLevelStart);
      }
    }
  }

  void _addUniqueNodes(Map<TreeRenderNode, TreeRenderNode> nodes, TreeRenderNode newNode) {
    TreeRenderNode? old = nodes[newNode];
    if (old != null) {
      throw FlutterError("Node used more than once in tree: %s");
    }
    nodes[newNode] = newNode;
    for (TreeRenderNode n in newNode.children) {
      _addUniqueNodes(nodes, n);
    }
  }

  void checkTree() {
    Map<TreeRenderNode, TreeRenderNode> nodes = {};
    _addUniqueNodes(nodes, root);
  }

  num _getPrelim(TreeRenderNode? node) {
    return _prelimMap[node] ?? 0;
  }

  num _getChange(TreeRenderNode? node) {
    return _changeMap[node] ?? 0;
  }

  num _getShift(TreeRenderNode? node) {
    return _shiftMap[node] ?? 0;
  }

  num _getDistance(TreeRenderNode v, TreeRenderNode w) {
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

  num _nodeGap(TreeRenderNode v, TreeRenderNode w) {
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
