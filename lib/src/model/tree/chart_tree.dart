import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

typedef TreeFun<T, N extends ChartTree<T, N>> = bool Function(N node, int index, N startNode);

///通用的树节点抽象表示
abstract class ChartTree<T, N extends ChartTree<T, N>> extends RenderData<T> {
  N? parent;

  List<N> _childrenList = [];

  ///后代节点数
  int _count = 0;

  /// 当前节点的深度(root为0)
  int _deep = 0;

  ///整颗树最大的深度
  int maxDeep = 0;

  ///树的逻辑高度
  int _height = 0;

  num value = 0;

  ///节点中心位置和其大小
  num x = 0;
  num y = 0;
  Size size = Size.zero;

  ///缩放
  double scale = 1;
  bool _expand = true; //是否展开

  ChartTree(
    this.parent,
    List<N> children, {
    this.value = 0,
    this.maxDeep = -1,
    int deep = 0,
    super.id,
    super.name,
  }) {
    this._deep = deep;
    this._childrenList.addAll(children);
  }

  void removeChild(bool Function(ChartTree) filter) {
    _childrenList.removeWhere(filter);
  }

  ChartTree removeAt(int i) {
    return _childrenList.removeAt(i);
  }

  ChartTree removeFirst() {
    return removeAt(0);
  }

  ChartTree removeLast() {
    return removeAt(_childrenList.length - 1);
  }

  void removeWhere(bool Function(N) where, [bool iterator = false]) {
    if (!iterator) {
      _childrenList.removeWhere(where);
      return;
    }

    List<N> nodeList = [this as N];
    while (nodeList.isNotEmpty) {
      N first = nodeList.removeAt(0);
      first._childrenList.removeWhere(where);
      nodeList.addAll(first._childrenList);
    }
  }

  List<N> get children {
    return _childrenList;
  }

  List<N> get childrenReverse => List.from(_childrenList.reversed);

  bool get hasChild {
    return _childrenList.isNotEmpty;
  }

  bool get notChild {
    return _childrenList.isEmpty;
  }

  int get childCount => _childrenList.length;

  /// 自身在父节点中的索引 如果为-1表示没有父节点
  int get childIndex {
    if (parent == null) {
      return -1;
    }
    return parent!._childrenList.indexOf(this as N);
  }

  ///返回后代节点数
  ///调用该方法前必须先调用 computeCount，否则永远返回0
  int get count => _count;

  int get height => _height;

  int get deep => _deep;

  N childAt(int index) {
    return _childrenList[index];
  }

  N get firstChild {
    return childAt(0);
  }

  N get lastChild {
    return childAt(_childrenList.length - 1);
  }

  void add(N node) {
    if (node.parent != null && node.parent != this) {
      throw FlutterError('当前要添加的节点其父节点不为空');
    }
    node.parent = this as N;
    _childrenList.add(node);
  }

  void addAll(Iterable<N> nodes) {
    for (var node in nodes) {
      add(node);
    }
  }

  void remove(N node) {
    _childrenList.remove(node);
  }

  void clear() {
    var cs = _childrenList;
    _childrenList = [];
    for (var c in cs) {
      c.parent = null;
    }
  }

  /// 返回其所有的叶子结点
  List<N> leaves() {
    List<N> resultList = [];
    eachBefore((N a, int b, N c) {
      if (a.notChild) {
        resultList.add(a);
      }
      return false;
    });
    return resultList;
  }

  /// 返回其所有后代节点
  List<N> descendants() {
    return iterator();
  }

  ///返回其后代所有节点(按照拓扑结构)
  List<N> iterator() {
    List<N> resultList = [];
    N? node = this as N;
    List<N> current = [];
    List<N> next = [node];
    List<N> children = [];
    do {
      current = List.from(next.reversed);
      next = [];
      while (current.isNotEmpty) {
        node = current.removeLast();
        resultList.add(node);
        children = node.children;
        if (children.isNotEmpty) {
          for (int i = 0, n = children.length; i < n; ++i) {
            next.add(children[i]);
          }
        }
      }
    } while (next.isNotEmpty);

    return resultList;
  }

  /// 返回从当前节点开始的祖先节点
  List<N> ancestors() {
    List<N> resultList = [this as N];
    N? node = this as N;
    while ((node = node?.parent) != null) {
      resultList.add(node!);
    }
    return resultList;
  }

  ///层序遍历
  List<List<N>> levelEach([int level = -1]) {
    List<List<N>> resultList = [];
    List<N> list = [this as N];
    List<N> next = [];
    if (level <= 0) {
      level = 2 ^ 16;
    }
    while (list.isNotEmpty && level > 0) {
      resultList.add(list);
      for (var c in list) {
        next.addAll(c.children);
      }
      list = next;
      next = [];
      level--;
    }
    return resultList;
  }

  N each(TreeFun<T, N> callback, [bool exitUseBreak = true]) {
    int index = -1;
    for (var node in iterator()) {
      if (callback.call(node, ++index, this as N)) {
        break;
      }
    }
    return this as N;
  }

  ///先序遍历
  N eachBefore(TreeFun<T, N> callback, [bool exitUseBreak = true]) {
    List<N> nodes = [this as N];
    List<N> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      N node = nodes.removeLast();
      if (callback.call(node, ++index, this as N)) {
        if (exitUseBreak) {
          break;
        }
        continue;
      }
      children = node._childrenList;
      nodes.addAll(children.reversed);
    }
    return this as N;
  }

  ///后序遍历
  N eachAfter(TreeFun<T, N> callback, [bool exitUseBreak = true]) {
    List<N> nodes = [this as N];
    List<N> next = [];
    List<N> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      N node = nodes.removeAt(nodes.length - 1);
      next.add(node);
      children = node._childrenList;
      nodes.addAll(children);
    }
    while (next.isNotEmpty) {
      N node = next.removeAt(next.length - 1);
      if (callback.call(node, ++index, this as N)) {
        break;
      }
    }
    return this as N;
  }

  ///在子节点中查找对应节点
  N? findInChildren(TreeFun<T, N> callback) {
    int index = -1;
    for (N node in _childrenList) {
      if (callback.call(node, ++index, this as N)) {
        return node;
      }
    }
    return null;
  }

  N? find(TreeFun<T, N> callback) {
    N? result;
    each((node, index, startNode) {
      if (callback.call(node, index, this as N)) {
        result = node;
        return true;
      }
      return false;
    });
    return result;
  }

  /// 从当前节点开始查找深度等于给定深度的节点
  /// 广度优先遍历 [only]==true 只返回对应层次的,否则返回<=
  List<N> depthNode(int depth, [bool only = true]) {
    if (deep > depth) {
      return [];
    }
    List<N> resultList = [];
    List<N> tmp = [this as N];
    List<N> next = [];
    while (tmp.isNotEmpty) {
      for (var node in tmp) {
        if (only) {
          if (node.deep == depth) {
            resultList.add(node);
          } else {
            next.addAll(node._childrenList);
          }
        } else {
          resultList.add(node);
          next.addAll(node._childrenList);
        }
      }
      tmp = next;
      next = [];
    }
    return resultList;
  }

  ///返回当前节点的后续的所有Link
  List<Link<N>> links() {
    List<Link<N>> links = [];
    each((node, index, startNode) {
      if (node != this && node.parent != null) {
        links.add(Link(node.parent!, node));
      }
      return false;
    });
    return links;
  }

  ///返回从当前节点到指定节点的最短路径
  List<N> path(N target) {
    N? start = this as N;
    N? end = target;
    N? ancestor = minCommonAncestor(start, end);
    List<N> nodes = [start];
    while (ancestor != start) {
      start = start?.parent;
      if (start != null) {
        nodes.add(start);
      }
    }
    var k = nodes.length;
    while (end != ancestor) {
      nodes.insert(k, end!);
      end = end.parent;
    }
    return nodes;
  }

  N sort(int Function(N, N) compare, [bool iterator = true]) {
    if (iterator) {
      return eachBefore((N node, b, c) {
        if (node.childCount > 1) {
          node._childrenList.sort(compare);
        }
        return false;
      });
    }
    _childrenList.sort(compare);
    return this as N;
  }

  ///计算当前节点值
  ///如果给定了回调,那么将使用给定的回调进行值统计
  ///否则直接使用 _value 统计
  N sum([num Function(N)? valueCallback]) {
    return eachAfter((N node, b, c) {
      num sum = valueCallback == null ? node.value : valueCallback(node);
      List<N> children = node._childrenList;
      int i = children.length;
      while (--i >= 0) {
        sum += children[i].value;
      }
      node.value = sum;
      return false;
    });
  }

  ///返回当前节点下最左边的叶子节点
  N leafLeft() {
    List<N> children = [];
    N node = this as N;
    while ((children = node.children).isNotEmpty) {
      node = children[0];
    }
    return node;
  }

  N leafRight() {
    List<N> children = [];
    N node = this as N;
    while ((children = node.children).isNotEmpty) {
      node = children[children.length - 1];
    }
    return node;
  }

  /// 计算当前节点的后代节点数
  int computeCount() {
    eachAfter((N node, b, c) {
      int sum = 0;
      List<N> children = node._childrenList;
      int i = children.length;
      if (i == 0) {
        sum = 1;
      } else {
        while (--i >= 0) {
          sum += children[i]._count;
        }
      }
      node._count = sum;
      return false;
    });
    return _count;
  }

  /// 计算树的高度
  void computeHeight([int initHeight = 0]) {
    List<List<N>> levelList = [];
    List<N> tmp = [this as N];
    List<N> next = [];
    while (tmp.isNotEmpty) {
      levelList.add(tmp);
      next = [];
      for (var c in tmp) {
        next.addAll(c.children);
      }
      tmp = next;
    }
    int c = levelList.length;
    for (int i = 0; i < c; i++) {
      for (var node in levelList[i]) {
        node._height = c - i - 1;
      }
    }
  }

  ///设置深度
  void setDeep(int deep, [bool iterator = true]) {
    this._deep = deep;
    if (iterator) {
      for (var node in _childrenList) {
        node.setDeep(deep + 1, true);
      }
    }
  }

  void setMaxDeep(int maxDeep, [bool iterator = true]) {
    this.maxDeep = maxDeep;
    if (iterator) {
      for (var node in _childrenList) {
        node.setMaxDeep(maxDeep, iterator);
      }
    }
  }

  //设置树高度
  void setHeight(int height, [bool iterator = true]) {
    this._height = height;
    if (iterator) {
      for (var node in _childrenList) {
        node.setHeight(height - 1, true);
      }
    }
  }

  int findMaxDeep() {
    int i = 0;
    leaves().forEach((element) {
      i = m.max(i, element.deep);
    });
    return i;
  }

  //=======坐标相关的操作========

  ///找到一个节点是否在[offset]范围内
  N? findNodeByOffset(Offset offset, [bool useRadius = true, bool shordSide = true]) {
    double r = (shordSide ? size.shortestSide : size.longestSide) / 2;
    r *= r;
    return find((node, index, startNode) {
      if (useRadius) {
        double a = (offset.dx - node.x).abs();
        double b = (offset.dy - node.y).abs();
        return (a * a + b * b) <= r;
      } else {
        return node.position.contains(offset);
      }
    });
  }

  void translate(num dx, num dy) {
    this.each((node, index, startNode) {
      node.x += dx;
      node.y += dy;
      return false;
    });
  }

  void right2Left() {
    Rect bound = getBoundBox();
    this.each((node, index, startNode) {
      node.x = node.x - (node.x - bound.left) * 2;
      return false;
    });
  }

  void bottom2Top() {
    Rect bound = getBoundBox();
    this.each((node, index, startNode) {
      node.y = node.y - (node.y - bound.top) * 2;
      return false;
    });
  }

  ///获取包围整个树的巨星
  Rect getBoundBox() {
    num left = x;
    num right = x;
    num top = y;
    num bottom = y;
    this.each((node, index, startNode) {
      left = m.min(left, node.x);
      top = m.min(top, node.y);
      right = m.max(right, node.x);
      bottom = m.max(bottom, node.y);
      return false;
    });
    return Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  Offset get center {
    return Offset(x.toDouble(), y.toDouble());
  }

  set center(Offset offset) {
    x = offset.dx;
    y = offset.dy;
  }

  Rect get position => Rect.fromCenter(center: center, width: size.width, height: size.height);

  set position(Rect rect) {
    Offset center = rect.center;
    x = center.dx;
    y = center.dy;
    size = rect.size;
  }

  double get left => x - size.width / 2;

  double get top => y - size.height / 2;

  double get right => x + size.width / 2;

  double get bottom => y + size.height / 2;

  ///从复制当前节点及其后代
  ///复制后的节点没有parent
  ChartTree copy(ChartTree Function(ChartTree?, ChartTree) build, [int deep = 0]) {
    return _innerCopy(build, null, deep);
  }

  ChartTree _innerCopy(ChartTree Function(ChartTree?, ChartTree) build, ChartTree? parent, int deep) {
    ChartTree node = build.call(parent, this);
    node.parent = parent;
    node._deep = deep;
    node.value = value;
    node._height = _height;
    node._count = _count;
    node._expand = _expand;
    for (var ele in _childrenList) {
      node.add(ele._innerCopy(build, node, deep + 1));
    }
    return node;
  }

  set expand(bool b) {
    _expand = b;
    for (var element in _childrenList) {
      element.expand = b;
    }
  }

  void setExpand(bool e, [bool iterator = true]) {
    _expand = e;
    if (iterator) {
      for (var element in _childrenList) {
        element.setExpand(e, iterator);
      }
    }
  }

  bool get expand => _expand;

  bool get isLeaf => childCount <= 0;

  @override
  String toString() {
    return "$runtimeType:\ndeep:$deep height:$height maxDeep:$maxDeep\nchildCount:$childCount\n";
  }

  ///返回 节点 a,b的最小公共祖先
  static N? minCommonAncestor<T, N extends ChartTree<T, N>>(N a, N b) {
    if (a == b) return a;
    var aNodes = a.ancestors();
    var bNodes = b.ancestors();
    N? c;
    a = aNodes.removeLast();
    b = bNodes.removeLast();
    while (a == b) {
      c = a;
      a = aNodes.removeLast();
      b = bNodes.removeLast();
    }
    return c;
  }
}