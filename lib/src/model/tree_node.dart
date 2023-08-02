import 'dart:math';

import 'package:flutter/widgets.dart';

import 'link.dart';

typedef TreeFun<T extends TreeNode<T>> = bool Function(T node, int index, T startNode);

///通用的树节点抽象表示
class TreeNode<T extends TreeNode<T>> {
  T? parent;
  final List<T> _childrenList = [];

  ///当前节点的值(永远>=0)
  num _value = 0;

  ///后代节点数
  int _count = 0;

  /// 当前节点的深度(root为0)
  int _deep = 0;

  ///整颗树最大的深度
  int maxDeep = 0;

  ///树的逻辑高度
  int _height = 0;

  bool _expand = true; //是否展开
  bool select = false; //是否被选中

  TreeNode(this.parent, {this.maxDeep = -1, int deep = 0, num value = 0}) {
    _value = value;
    this._deep = deep;
    if (_value < 0) {
      throw FlutterError('Value must >=0');
    }
  }

  void removeChild(bool Function(T) filter) {
    _childrenList.removeWhere(filter);
  }

  T removeAt(int i) {
    return _childrenList.removeAt(i);
  }

  T removeFirst() {
    return removeAt(0);
  }

  T removeLast() {
    return removeAt(_childrenList.length - 1);
  }

  void removeWhere(bool Function(T) where, [bool iterator = false]) {
    if (!iterator) {
      _childrenList.removeWhere(where);
      return;
    }

    List<T> nodeList = [this as T];
    while (nodeList.isNotEmpty) {
      T first = nodeList.removeAt(0);
      first._childrenList.removeWhere(where);
      nodeList.addAll(first._childrenList);
    }
  }

  List<T> get children {
    return _childrenList;
  }

  List<T> get childrenReverse => List.from(_childrenList.reversed);

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
    return parent!._childrenList.indexOf(this as T);
  }

  ///返回后代节点数
  ///调用该方法前必须先调用 computeCount，否则永远返回0
  int get count => _count;

  int get height => _height;

  int get deep => _deep;

  double get value => _value.toDouble();

  set value(num v) {
    if (v < 0) {
      throw FlutterError('value 必须大于等于0¬');
    }
    _value = v;
  }

  T childAt(int index) {
    return _childrenList[index];
  }

  T get firstChild {
    return childAt(0);
  }

  T get lastChild {
    return childAt(_childrenList.length - 1);
  }

  void add(T node) {
    if (node.parent != null && node.parent != this) {
      throw FlutterError('当前要添加的节点其父节点不为空');
    }
    node.parent = this as T;
    _childrenList.add(node);
  }

  void remove(T node) {
    _childrenList.remove(node);
  }

  void clear() {
    _childrenList.clear();
  }

  /// 返回其所有的叶子结点
  List<T> leaves() {
    List<T> resultList = [];
    eachBefore((T a, int b, T c) {
      if (a.notChild) {
        resultList.add(a);
      }
      return false;
    });
    return resultList;
  }

  /// 返回其所有后代节点
  List<T> descendants() {
    return iterator();
  }

  ///返回其后代所有节点(按照拓扑结构)
  List<T> iterator() {
    List<T> resultList = [];
    T? node = this as T;
    List<T> current = [];
    List<T> next = [node];
    List<T> children = [];
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
  List<T> ancestors() {
    List<T> resultList = [this as T];
    T? node = this as T;
    while ((node = node?.parent) != null) {
      resultList.add(node!);
    }
    return resultList;
  }

  T each(TreeFun<T> callback) {
    int index = -1;
    for (var node in iterator()) {
      if (callback.call(node, ++index, this as T)) {
        break;
      }
    }
    return this as T;
  }

  ///先序遍历
  T eachBefore(TreeFun<T> callback) {
    List<T> nodes = [this as T];
    List<T> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      T node = nodes.removeLast();
      if (callback.call(node, ++index, this as T)) {
        break;
      }
      children = node._childrenList;
      nodes.addAll(children.reversed);
    }
    return this as T;
  }

  ///后序遍历
  T eachAfter(TreeFun<T> callback) {
    List<T> nodes = [this as T];
    List<T> next = [];
    List<T> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      T node = nodes.removeAt(nodes.length - 1);
      next.add(node);
      children = node._childrenList;
      nodes.addAll(children);
    }
    while (next.isNotEmpty) {
      TreeNode node = next.removeAt(next.length - 1);
      if (callback.call(node as T, ++index, this as T)) {
        break;
      }
    }
    return this as T;
  }

  ///在子节点中查找对应节点
  T? findInChildren(TreeFun<T> callback) {
    int index = -1;
    for (T node in _childrenList) {
      if (callback.call(node, ++index, this as T)) {
        return node;
      }
    }
    return null;
  }

  T? find(TreeFun<T> callback) {
    T? result;
    each((node, index, startNode) {
      if (callback.call(node, index, this as T)) {
        result = node;
        return true;
      }
      return false;
    });
    return result;
  }

  /// 从当前节点开始查找深度等于给定深度的节点
  /// 广度优先遍历 [only]==true 只返回对应层次的,否则返回<=
  List<T> depthNode(int depth, [bool only = true]) {
    if (deep > depth) {
      return [];
    }
    List<T> resultList = [];
    List<T> tmp = [this as T];
    List<T> next = [];
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
  List<Link<T>> links() {
    List<Link<T>> links = [];
    each((node, index, startNode) {
      if (node != this && node.parent != null) {
        links.add(Link(node.parent!, node));
      }
      return false;
    });
    return links;
  }

  ///返回从当前节点到指定节点的最短路径
  List<T> path(T target) {
    T? start = this as T;
    T? end = target;
    T? ancestor = minCommonAncestor(start, end);
    List<T> nodes = [start];
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

  T sort(int Function(T, T) compare, [bool iterator = true]) {
    if (iterator) {
      return eachBefore((T node, b, c) {
        if (node.hasChild) {
          node._childrenList.sort(compare);
        }
        return false;
      });
    }
    _childrenList.sort(compare);
    return this as T;
  }

  ///计算当前节点值
  ///如果给定了回调,那么将使用给定的回调进行值统计
  ///否则直接使用 _value 统计
  T sum([num Function(T)? valueCallback]) {
    return eachAfter((T node, b, c) {
      num sum = valueCallback == null ? node._value : valueCallback(node);
      List<TreeNode> children = node._childrenList;
      int i = children.length;
      while (--i >= 0) {
        sum += children[i].value;
      }
      node._value = sum;
      return false;
    });
  }

  ///返回当前节点下最左边的叶子节点
  T leafLeft() {
    List<T> children = [];
    T node = this as T;
    while ((children = node.children).isNotEmpty) {
      node = children[0];
    }
    return node;
  }

  T leafRight() {
    List<T> children = [];
    T node = this as T;
    while ((children = node.children).isNotEmpty) {
      node = children[children.length - 1];
    }
    return node;
  }

  /// 计算当前节点的后代节点数
  int computeCount() {
    eachAfter((T node, b, c) {
      int sum = 0;
      List<T> children = node._childrenList;
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
    List<List<T>> levelList=[];
    List<T> tmp = [this as T];
    List<T> next = [];
    while (tmp.isNotEmpty) {
      levelList.add(tmp);
      next=[];
     for(var c in tmp){
       next.addAll(c.children);
     }
      tmp=next;
    }
    int c=levelList.length;
    for(int i=0;i<c;i++){
     for (var node in levelList[i]) {
       node._height=c-i-1;
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
      i = max(i, element.deep);
    });
    return i;
  }

  //=======坐标相关的操作========

  ///节点中心位置和其大小
  num x = 0;
  num y = 0;
  Size size = Size.zero;

  ///找到一个节点是否在[offset]范围内
  T? findNodeByOffset(Offset offset, [bool useRadius = true, bool shordSide = true]) {
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
      left = min(left, node.x);
      top = min(top, node.y);
      right = max(right, node.x);
      bottom = max(bottom, node.y);
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
  T copy(T Function(T?, T) build, [int deep = 0]) {
    return _innerCopy(build, null, deep);
  }

  T _innerCopy(T Function(T?, T) build, T? parent, int deep) {
    T node = build.call(parent, this as T);
    node.parent = parent;
    node._deep = deep;
    node._value = _value;
    node._height = _height;
    node._count = _count;
    node._expand = _expand;
    node.select = select;
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

  ///返回 节点 a,b的最小公共祖先
  static T? minCommonAncestor<T extends TreeNode<T>>(T a, T b) {
    if (a == b) return a;
    var aNodes = a.ancestors();
    var bNodes = b.ancestors();
    T? c;
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

T toTree<D, T extends TreeNode<T>>(D data,
    List<D> Function(D) childrenCallback,
    T Function(T?, D) build, {
      int deep = 0,
      T? parent,
      int Function(T, T)? sort,
    }) {
  T root = build.call(parent, data);
  root._deep = deep;
  root.parent = parent;
  for (var child in childrenCallback.call(data)) {
    root.add(toTree<D, T>(child, childrenCallback, build, deep: deep + 1, parent: root));
  }
  if (sort != null) {
    root._childrenList.sort((a, b) {
      return sort.call(a, b);
    });
  }
  return root;
}

D convertTree<T extends TreeNode<T>, D extends TreeNode<D>>(T tree, D Function(D?, T) build, {D? parent}) {
  D root = build.call(parent, tree);
  for (var child in tree._childrenList) {
    root.add(convertTree<T, D>(child, build, parent: root));
  }
  return root;
}
