import 'dart:math' as math;
import 'dart:ui';

import 'package:e_chart/src/utils/list_util.dart';

import '../../utils/uuid_util.dart';
import '../quickselect/quick_select.dart';

/// RBush 是一个高性能的点或矩形空间分割库，用于点和矩形的 2D 空间索引。
/// 它基于具有批量插入支持的R树 数据结构。
/// 空间索引是点和矩形的特殊数据结构，允许您非常有效地执行“此边界框中的所有项目”等查询
///
/// 移植自 https://github.com/mourner/rbush
///
/// TODO 后续对数据的封装进行优化
class RBush<T> {
  late final int maxEntries;
  late final int minEntries;

  late RNode<T> _root;

  RBush([int maxEntries = 9]) {
    this.maxEntries = math.max(4, maxEntries);
    minEntries = math.max(2, (this.maxEntries * 0.4).ceil());
    clear();
  }

  List<RNode<T>> all() {
    return _all(_root, []);
  }

  ///搜索与给定边界框相交的数据项
  List<RNode<T>> search(Rect bbox) {
    RNode<T>? node = _root;
    List<RNode<T>> result = [];
    if (!_intersects(bbox, node)) {
      return result;
    }
    List<RNode<T>> nodesToSearch = [];
    while (node != null) {
      for (int i = 0; i < node.children.length; i++) {
        var child = node.children[i];
        var childBBox = child;
        if (_intersects(bbox, childBBox)) {
          if (node.leaf) {
            result.add(child);
          } else if (_contains2(bbox, childBBox)) {
            _all(child, result);
          } else {
            nodesToSearch.add(child);
          }
        }
      }
      node = removeLastOrNull<RNode<T>>(nodesToSearch);
    }
    return result;
  }

  ///如果有任何项与给定边界框相交，则返回 true，否则 false
  bool collides(Rect bbox) {
    RNode? node = _root;
    if (!_intersects(bbox, node)) return false;
    const nodesToSearch = [];
    while (node != null) {
      for (int i = 0; i < node.children.length; i++) {
        var child = node.children[i];
        var childBBox = child;
        if (_intersects(bbox, childBBox)) {
          if (node.leaf || _contains2(bbox, childBBox)) {
            return true;
          }
          nodesToSearch.add(child);
        }
      }
      node = removeLastOrNull(nodesToSearch);
    }
    return false;
  }

  RBush<T> addAll(List<RNode<T>> data) {
    if (data.isEmpty) {
      return this;
    }

    if (data.length < minEntries) {
      for (int i = 0; i < data.length; i++) {
        this.add(data[i]);
      }
      return this;
    }

    // 使用OMT算法从头开始用给定的数据递归地构建树
    var node = this._build(copyList(data), 0, data.length - 1, 0);

    if (_root.children.isEmpty) {
      this._root = node;
    } else if (_root.height == node.height) {
      // 如果树的高度相同，则分开生根
      this._splitRoot(this._root, node);
    } else {
      if (this._root.height < node.height) {
        //如果树的高度相同，则分开生根
        var tmpNode = this._root;
        this._root = node;
        node = tmpNode;
      }
      // 如果树的高度相同，则分开生根
      _insert(node, this._root.height - node.height - 1);
    }
    return this;
  }

  RBush<T> add(RNode<T> item) {
    _insert(item, this._root.height - 1);
    return this;
  }

  RBush<T> clear() {
    this._root = _createNode([]);
    return this;
  }

  RBush<T> remove(RNode item) {
    RNode? node = this._root;
    RNode bbox = item;
    List<RNode> path = [];
    List<int> indexes = [];
    int i = 0;
    RNode? parent;
    bool goingUp = false;

    // 深度优先遍历树
    while (node != null || path.isNotEmpty) {
      if (node == null) {
        node = removeLastOrNull(path)!;
        parent = path[path.length - 1];
        i = removeLastOrNull(indexes)!;
        goingUp = true;
      }
      if (node.leaf) {
        int index = findItem(item, node.children);
        if (index != -1) {
          //如果被找到 则删除该项并向上压缩树
          node.children.removeRange(index, index + 1);
          path.add(node);
          this._condense(path);
          return this;
        }
      }
      if (!goingUp && !node.leaf && _contains(node, bbox)) {
        // 向下查找
        path.add(node);
        indexes.add(i);
        i = 0;
        parent = node;
        node = node.children[0];
      } else if (parent != null) {
        // 向右查找
        i++;
        node = parent.children[i];
        goingUp = false;
      } else {
        // nothing found
        node = null;
      }
    }
    return this;
  }

  int compareMinX(RNode a, RNode b) {
    return a.minX.compareTo(b.minX);
  }

  int compareMinY(RNode a, RNode b) {
    return a.minY.compareTo(b.minY);
  }

  List<RNode<T>> _all(RNode<T>? node, List<RNode<T>> result) {
    List<RNode<T>> nodesToSearch = [];
    while (node != null) {
      if (node.leaf) {
        result.addAll(node.children);
      } else {
        nodesToSearch.addAll(node.children);
      }
      node = removeLastOrNull(nodesToSearch);
    }
    return result;
  }

  RNode<T> _build(List<RNode<T>> items, int left, int right, int height) {
    int N = right - left + 1;
    int M = maxEntries;
    RNode<T>? node;

    if (N <= M) {
      node = _createNode(List.from(items.getRange(left, right + 1)));
      _calcBBox(node);
      return node;
    }

    if (height == 0) {
      //树的目标高度
      height = (math.log(N) / math.log(M)).ceil();
      //根条目以最大限度地提高存储利用率
      M = (N / math.pow(M, height - 1)).ceil();
    }

    node = _createNode([]);
    node.leaf = false;
    node.height = height;

    // 将物品分成M块，大部分为正方形
    int n2 = (N / M).ceil();
    int n1 = n2 * math.sqrt(M).ceil();

    _multiSelect(items, left, right, n1, this.compareMinX);

    for (int i = left; i <= right; i += n1) {
      int right2 = math.min(i + n1 - 1, right);
      _multiSelect(items, i, right2, n2, this.compareMinY);

      for (int j = i; j <= right2; j += n2) {
        int right3 = math.min(j + n2 - 1, right2);
        //递归打包每个条目
        node.children.add(this._build(items, j, right3, height - 1));
      }
    }
    _calcBBox(node);
    return node;
  }

  RNode _chooseSubtree(RNode bbox, RNode node, int level, List<RNode> path) {
    while (true) {
      path.add(node);
      if (node.leaf || path.length - 1 == level) break;

      num minArea = double.infinity;
      num minEnlargement = double.infinity;
      RNode? targetNode;
      for (int i = 0; i < node.children.length; i++) {
        var child = node.children[i];
        var area = _bboxArea(child);
        var enlargement = _enlargedArea(bbox, child) - area;

        // 选择放大面积最小的条目
        if (enlargement < minEnlargement) {
          minEnlargement = enlargement;
          minArea = area < minArea ? area : minArea;
          targetNode = child;
        } else if (enlargement == minEnlargement) {
          // 否则选择面积最小的
          if (area < minArea) {
            minArea = area;
            targetNode = child;
          }
        }
      }
      if (targetNode != null) {
        node = targetNode;
      } else {
        node = node.children[0];
      }
    }
    return node;
  }

  void _insert(RNode<T> item, int level) {
    var bbox = item;
    List<RNode<T>> insertPath = [];
    var node = this._chooseSubtree(bbox, _root, level, insertPath);
    node.children.add(item);
    _extend(node, bbox);
    while (level >= 0) {
      if (insertPath[level].children.length > maxEntries) {
        _split(insertPath, level);
        level--;
      } else {
        break;
      }
    }
    this._adjustParentBBoxes(bbox, insertPath, level);
  }

  //将溢出节点一分为二
  void _split(List<RNode<T>> insertPath, int level) {
    var node = insertPath[level];
    int M = node.children.length;
    int m = minEntries;
    _chooseSplitAxis(node, m, M);
    int splitIndex = _chooseSplitIndex(node, m, M);

    List<RNode<T>> removeList = List.from(node.children.getRange(splitIndex, node.children.length));
    node.children.removeRange(splitIndex, node.children.length);
    var newNode = _createNode(removeList);

    newNode.height = node.height;
    newNode.leaf = node.leaf;

    _calcBBox(node);
    _calcBBox(newNode);

    if (level != 0) {
      insertPath[level - 1].children.add(newNode);
    } else {
      _splitRoot(node, newNode);
    }
  }

  void _splitRoot(RNode<T> node, RNode<T> newNode) {
    //划分根节点
    this._root = _createNode([node, newNode]);
    this._root.height = node.height + 1;
    this._root.leaf = false;
    _calcBBox(this._root);
  }

  int _chooseSplitIndex(RNode node, int m, int M) {
    int index = 0;
    num minOverlap = double.infinity;
    num minArea = double.infinity;
    for (int i = m; i <= M - m; i++) {
      var bbox1 = _distBBox(node, 0, i);
      var bbox2 = _distBBox(node, i, M);

      var overlap = _intersectionArea(bbox1, bbox2);
      var area = _bboxArea(bbox1) + _bboxArea(bbox2);

      // 选择重叠最小的
      if (overlap < minOverlap) {
        minOverlap = overlap;
        index = i;

        minArea = area < minArea ? area : minArea;
      } else if (overlap == minOverlap) {
        // 否则选择面积最小的
        if (area < minArea) {
          minArea = area;
          index = i;
        }
      }
    }
    if (index != 0) {
      return index;
    }
    return M - m;
  }

  // 按要拆分的最佳轴对节点子级进行排序
  _chooseSplitAxis(RNode node, int m, int M) {
    var compareMinX = node.leaf ? this.compareMinX : _compareNodeMinX;
    var compareMinY = node.leaf ? this.compareMinY : _compareNodeMinY;
    var xMargin = _allDistMargin(node, m, M, compareMinX);
    var yMargin = _allDistMargin(node, m, M, compareMinY);

    //如果x的总分布裕度值最小，则按minX排序，否则按minY排序
    if (xMargin < yMargin) node.children.sort(compareMinX);
  }

  // 所有可能的分裂分布的总裕度，其中每个节点至少满m
  double _allDistMargin(RNode node, int m, int M, compare) {
    node.children.sort(compare);

    var leftBBox = _distBBox(node, 0, m);
    var rightBBox = _distBBox(node, M - m, M);
    num margin = _bboxMargin(leftBBox) + _bboxMargin(rightBBox);

    for (int i = m; i < M - m; i++) {
      var child = node.children[i];
      _extend(leftBBox, child);
      margin += _bboxMargin(leftBBox);
    }
    for (int i = M - m - 1; i >= m; i--) {
      var child = node.children[i];
      _extend(rightBBox, child);
      margin += _bboxMargin(rightBBox);
    }
    return margin.toDouble();
  }

  void _adjustParentBBoxes(RNode bbox, List<RNode> path, int level) {
    //沿着给定的树路径调整框
    for (int i = level; i >= 0; i--) {
      _extend(path[i], bbox);
    }
  }

  _condense(List<RNode> path) {
    // 遍历路径，删除空节点并更新bboxes
    List<RNode> siblings;
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i].children.isEmpty) {
        if (i > 0) {
          siblings = path[i - 1].children;
          int index = siblings.indexOf(path[i]);
          siblings.removeRange(index, index + 1);
        } else {
          this.clear();
        }
      } else {
        _calcBBox(path[i]);
      }
    }
  }

  int findItem(RNode item, List<RNode> items) {
    return items.indexOf(item);
  }

  //=========================
//计算从节点的孩子节点中计算bbox
  void _calcBBox(RNode node) {
    _distBBox(node, 0, node.children.length, node);
  }

  //从k到p-1节点子节点的最小边界矩形
  RNode _distBBox(RNode node, int k, int p, [RNode? destNode]) {
    destNode ??= _createNode([]);
    destNode.minX = double.infinity;
    destNode.minY = double.infinity;
    destNode.maxX = -double.infinity;
    destNode.maxY = -double.infinity;
    for (int i = k; i < p; i++) {
      var child = node.children[i];
      _extend(destNode, child);
    }
    return destNode;
  }

  RNode _extend(RNode a, RNode b) {
    a.minX = math.min(a.minX, b.minX);
    a.minY = math.min(a.minY, b.minY);
    a.maxX = math.max(a.maxX, b.maxX);
    a.maxY = math.max(a.maxY, b.maxY);
    return a;
  }

  int _compareNodeMinX(RNode a, RNode b) {
    return a.minX.compareTo(b.minX);
  }

  int _compareNodeMinY(RNode a, RNode b) {
    return a.minY.compareTo(b.minY);
  }

  double _bboxArea(RNode a) {
    return (a.maxX - a.minX) * (a.maxY - a.minY);
  }

  double _bboxMargin(RNode a) {
    return (a.maxX - a.minX) + (a.maxY - a.minY);
  }

  double _enlargedArea(RNode a, RNode b) {
    return (math.max(b.maxX, a.maxX) - math.min(b.minX, a.minX)) *
        (math.max(b.maxY, a.maxY) - math.min(b.minY, a.minY));
  }

  double _intersectionArea(RNode a, RNode b) {
    var minX = math.max(a.minX, b.minX);
    var minY = math.max(a.minY, b.minY);
    var maxX = math.min(a.maxX, b.maxX);
    var maxY = math.min(a.maxY, b.maxY);

    return math.max(0, maxX - minX) * math.max(0, maxY - minY);
  }

  bool _contains(RNode a, RNode b) {
    return a.minX <= b.minX && a.minY <= b.minY && b.maxX <= a.maxX && b.maxY <= a.maxY;
  }

  bool _contains2(Rect a, RNode b) {
    return a.left <= b.minX && a.top <= b.minY && b.maxX <= a.right && b.maxY <= a.bottom;
  }

  bool _intersects(Rect a, RNode b) {
    return b.minX <= a.right && b.minY <= a.bottom && b.maxX >= a.left && b.maxY >= a.top;
  }

  RNode<T> _createNode(List<RNode<T>>? children) {
    return RNode(
        height: 1,
        leaf: true,
        minX: double.infinity,
        minY: double.infinity,
        maxX: double.negativeInfinity,
        maxY: double.negativeInfinity,
        children: children);
  }

  void _multiSelect(List<RNode> arr, int left, int right, int n, int Function(RNode, RNode) compare) {
    List<int> stack = [left, right];

    while (stack.isNotEmpty) {
      right = stack.removeLast();
      left = stack.removeLast();
      if (right - left <= n) continue;
      int mid = left + ((right - left) / n / 2).ceil() * n;
      quickSelect(arr, mid, left, right, compare);
      stack.addAll([left, mid, mid, right]);
    }
  }
}

class RNode<T> {
  late final String id;
  List<RNode<T>> children = [];
  int height;
  bool leaf;
  late double minX;
  late double minY;
  late double maxX;
  late double maxY;

  T? data;

  RNode({
    this.height = 1,
    this.leaf = true,
    this.minX = double.infinity,
    this.minY = double.infinity,
    this.maxX = double.negativeInfinity,
    this.maxY = double.negativeInfinity,
    List<RNode<T>>? children,
    this.data,
    String? id,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    if (children != null) {
      this.children = children;
    }
  }

  RNode.fromRect(
    Rect rect, {
    this.height = 1,
    this.leaf = true,
    this.data,
    String? id,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    children = [];
    minX = rect.left;
    minY = rect.top;
    maxX = rect.right;
    maxY = rect.bottom;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is RNode && other.id == id;
  }
}
