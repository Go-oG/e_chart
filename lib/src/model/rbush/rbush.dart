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

  late RItem _data;

  RBush([int maxEntries = 9]) {
    this.maxEntries = math.max(4, maxEntries);
    minEntries = math.max(2, (this.maxEntries * 0.4).ceil());
    clear();
  }

  List<RItem> all() {
    return _all(_data, []);
  }

  ///搜索与给定边界框相交的数据项
  List<RItem> search(Rect bbox) {
    RItem? node = _data;
    List<RItem> result = [];
    if (!_intersects(bbox, node)) {
      return result;
    }
    var nodesToSearch = [];
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
      node = nodesToSearch.removeLast();
    }
    return result;
  }

  ///如果有任何项与给定边界框相交，则返回 true，否则 false
  bool collides(Rect bbox) {
    RItem? node = _data;
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
      node = nodesToSearch.removeLast();
    }
    return false;
  }

  RBush<T> addAll(List<RItem> data) {
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

    if (_data.children.isEmpty) {
      this._data = node;
    } else if (_data.height == node.height) {
      // 如果树的高度相同，则分开生根
      this._splitRoot(this._data, node);
    } else {
      if (this._data.height < node.height) {
        //如果树的高度相同，则分开生根
        var tmpNode = this._data;
        this._data = node;
        node = tmpNode;
      }
      // 如果树的高度相同，则分开生根
      this._insert(node, this._data.height - node.height - 1, true);
    }
    return this;
  }

  RBush<T> add(RItem item) {
    _insert(item, this._data.height - 1);
    return this;
  }

  RBush<T> clear() {
    this._data = _createNode([]);
    return this;
  }

  RBush<T> remove(RItem item) {
    RItem? node = this._data;
    RItem bbox = item;
    List<RItem> path = [];
    List<int> indexes = [];
    int i = 0;
    RItem? parent;
    bool goingUp = false;

    // 深度优先遍历树
    while (node != null || path.isNotEmpty) {
      if (node == null) {
        node = path.removeLast();
        parent = path[path.length - 1];
        i = indexes.removeLast();
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

  int compareMinX(RItem a, RItem b) {
    return a.minX.compareTo(b.minX);
  }

  int compareMinY(RItem a, RItem b) {
    return a.minY.compareTo(b.minY);
  }

  List<RItem> _all(RItem? node, List<RItem> result) {
    List<RItem> nodesToSearch = [];
    while (node != null) {
      if (node.leaf) {
        result.addAll(node.children);
      } else {
        nodesToSearch.addAll(node.children);
      }
      node = nodesToSearch.removeLast();
    }
    return result;
  }

  RItem _build(List<RItem> items, int left, int right, int height) {
    int N = right - left + 1;
    int M = maxEntries;
    RItem? node;

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

  RItem _chooseSubtree(RItem bbox, RItem node, int level, List<RItem> path) {
    while (true) {
      path.add(node);
      if (node.leaf || path.length - 1 == level) break;

      num minArea = double.infinity;
      num minEnlargement = double.infinity;
      RItem? targetNode;
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

  void _insert(RItem item, int level, [bool isNode = false]) {
    var bbox = item;
    List<RItem> insertPath = [];

    //找到容纳项目的最佳节点，同时保存路径上的所有节点
    var node = this._chooseSubtree(bbox, _data, level, insertPath);
    node.children.add(item);
    _extend(node, bbox);
    // 找到容纳项目的最佳节点，同时保存路径上的所有节点
    while (level >= 0) {
      if (insertPath[level].children.length > maxEntries) {
        _split(insertPath, level);
        level--;
      } else {
        break;
      }
    }
    // 沿插入路径调整矩形框范围
    this._adjustParentBBoxes(bbox, insertPath, level);
  }

  //将溢出节点一分为二
  void _split(List<RItem> insertPath, int level) {
    var node = insertPath[level];
    int M = node.children.length;
    int m = minEntries;
    _chooseSplitAxis(node, m, M);
    int splitIndex = _chooseSplitIndex(node, m, M);

    List<RItem> removeList = List.from(node.children.getRange(splitIndex, node.children.length));
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

  void _splitRoot(RItem node, RItem newNode) {
    //划分根节点
    this._data = _createNode([node, newNode]);
    this._data.height = node.height + 1;
    this._data.leaf = false;
    _calcBBox(this._data);
  }

  int _chooseSplitIndex(RItem node, int m, int M) {
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
  _chooseSplitAxis(RItem node, int m, int M) {
    var compareMinX = node.leaf ? this.compareMinX : _compareNodeMinX;
    var compareMinY = node.leaf ? this.compareMinY : _compareNodeMinY;
    var xMargin = _allDistMargin(node, m, M, compareMinX);
    var yMargin = _allDistMargin(node, m, M, compareMinY);

    //如果x的总分布裕度值最小，则按minX排序，否则按minY排序
    if (xMargin < yMargin) node.children.sort(compareMinX);
  }

  // 所有可能的分裂分布的总裕度，其中每个节点至少满m
  double _allDistMargin(RItem node, int m, int M, compare) {
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

  void _adjustParentBBoxes(RItem bbox, List<RItem> path, int level) {
    //沿着给定的树路径调整框
    for (int i = level; i >= 0; i--) {
      _extend(path[i], bbox);
    }
  }

  _condense(List<RItem> path) {
    // 遍历路径，删除空节点并更新bboxes
    List<RItem> siblings;
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

  int findItem(RItem item, List<RItem> items) {
    return items.indexOf(item);
  }

  //=========================
//计算从节点的孩子节点中计算bbox
  void _calcBBox(RItem node) {
    _distBBox(node, 0, node.children.length, node);
  }

  //从k到p-1节点子节点的最小边界矩形
  RItem _distBBox(RItem node, int k, int p, [RItem? destNode]) {
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

  RItem _extend(RItem a, RItem b) {
    a.minX = math.min(a.minX, b.minX);
    a.minY = math.min(a.minY, b.minY);
    a.maxX = math.max(a.maxX, b.maxX);
    a.maxY = math.max(a.maxY, b.maxY);
    return a;
  }

  int _compareNodeMinX(RItem a, RItem b) {
    return a.minX.compareTo(b.minX);
  }

  int _compareNodeMinY(RItem a, RItem b) {
    return a.minY.compareTo(b.minY);
  }

  double _bboxArea(RItem a) {
    return (a.maxX - a.minX) * (a.maxY - a.minY);
  }

  double _bboxMargin(RItem a) {
    return (a.maxX - a.minX) + (a.maxY - a.minY);
  }

  double _enlargedArea(RItem a, RItem b) {
    return (math.max(b.maxX, a.maxX) - math.min(b.minX, a.minX)) *
        (math.max(b.maxY, a.maxY) - math.min(b.minY, a.minY));
  }

  double _intersectionArea(RItem a, RItem b) {
    var minX = math.max(a.minX, b.minX);
    var minY = math.max(a.minY, b.minY);
    var maxX = math.min(a.maxX, b.maxX);
    var maxY = math.min(a.maxY, b.maxY);

    return math.max(0, maxX - minX) * math.max(0, maxY - minY);
  }

  bool _contains(RItem a, RItem b) {
    return a.minX <= b.minX && a.minY <= b.minY && b.maxX <= a.maxX && b.maxY <= a.maxY;
  }

  bool _contains2(Rect a, RItem b) {
    return a.left <= b.minX && a.top <= b.minY && b.maxX <= a.right && b.maxY <= a.bottom;
  }

  bool _intersects(Rect a, RItem b) {
    return b.minX <= a.right && b.minY <= a.bottom && b.maxX >= a.left && b.maxY >= a.top;
  }

  RItem _createNode(List<RItem> children) {
    return RItem(
      children,
      height: 1,
      leaf: true,
      minX: double.infinity,
      minY: double.infinity,
      maxX: double.negativeInfinity,
      maxY: double.negativeInfinity,
    );
  }

  void _multiSelect(List<RItem> arr, int left, int right, int n, int Function(RItem, RItem) compare) {
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

class RItem {
  late final String id;
  List<RItem> children;
  int height;
  bool leaf;
  double minX;
  double minY;
  double maxX;
  double maxY;

  dynamic data;

  RItem(
    this.children, {
    this.height = 1,
    this.leaf = true,
    this.minX = double.infinity,
    this.minY = double.infinity,
    this.maxX = double.negativeInfinity,
    this.maxY = double.negativeInfinity,
    String? id,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is RItem && other.id == id;
  }
}
