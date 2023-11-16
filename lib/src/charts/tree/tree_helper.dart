import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class TreeHelper extends LayoutHelper2<TreeData, TreeSeries> {
  TreeHelper(super.context, super.view, super.series);

  TreeData _rootNode = TreeData.empty;

  TreeData get rootNode => _rootNode;

  ///存放依赖关系
  //<parent-child>
  Map<TreeData, List<TreeData>> _childMap = {};

  //<child-parent>
  Map<TreeData, TreeData> _parentMap = {};

  final RBush<TreeData> _rBush = RBush(
    (p0) => p0.center.dx - p0.size.width / 2,
    (p0) => p0.center.dy - p0.size.height / 2,
    (p0) => p0.center.dx + p0.size.width / 2,
    (p0) => p0.center.dy + p0.size.height / 2,
  );

  void updateNodeList(TreeData root) {
    _rBush.clear();
    List<TreeData> list = root.iterator();
    _rBush.addAll(list);
    if (series.layout.optShowNode) {
      dataSet = _rBush.search(getViewPortRect());
    } else {
      dataSet = list;
    }
  }

  @override
  void onLayout(LayoutType type) {
    var root = series.data;
    initData2(root);
    _startLayout(root, true);
    _rootNode = root;
    updateNodeList(root);
  }

  void initData2(TreeData root) {
    Map<TreeData, List<TreeData>> childMap = {};
    //<child-parent>
    Map<TreeData, TreeData> parentMap = {};
    root.each((node, index, startNode) {
      if (node.hasChild) {
        childMap[node] = List.from(node.children);
      }
      var p = node.parent;
      if (p != null) {
        parentMap[node] = p;
      }
      node.dataIndex = index;
      node.attr.symbol = series.getSymbol(context, node);
      node.updateStyle(context, series);
      node.size = node.attr.symbol.size;
      return false;
    });
    root.sum((p0) => p0.value);
    root.computeHeight();
    int maxDeep = root.height;
    root.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      return false;
    });
    _childMap = childMap;
    _parentMap = parentMap;
  }

  void _startLayout(TreeData root, bool clearTranslation) {
    ///计算树的深度和高度
    root.setDeep(0);
    root.computeHeight();
    root.setMaxDeep(root.height);

    ///开始布局
    series.layout.onLayout(
        root,
        HierarchyOption<TreeSeries>(
          series,
          width,
          height,
          boxBound,
          globalBoxBound,
        ));

    ///布局完成计算偏移量并更新节点
    double x = series.center[0].convert(width);
    double y = series.center[1].convert(height);

    ///布局完成后，需要再次更新节点位置和大小
    if (clearTranslation) {
      translationX = translationY = 0;
    }

    ///root中心点坐标
    var center = root.center;
    if (!series.rootInCenter) {
      center = root.getBoundBox().center;
    }
    double dx = x - center.dx;
    double dy = y - center.dy;
    if (dx != 0 || dy != 0) {
      root.each((node, index, startNode) {
        node.x += dx;
        node.y += dy;
        return false;
      });
    }
  }

  @override
  void onClick(Offset localOffset) {
    var offset = localOffset.translate(-translationX, -translationY);
    var node = findData(offset);

    if (node == null) {
      var oh = oldHoverData;
      oldHoverData = null;
      if (oh == null) {
        return;
      }
      oh.removeStates([ViewState.hover, ViewState.selected]);
      oh.updateStyle(context, series);
      sendHoverEndEvent(oh);
      notifyLayoutUpdate();
      return;
    }

    if (node != oldHoverData) {
      var oh = oldHoverData;
      if (oh != null) {
        oldHoverData = null;
        oh.removeStates([ViewState.hover, ViewState.selected]);
        oh.updateStyle(context, series);
        sendHoverEndEvent(oh);
      }
      node.addStates([ViewState.hover, ViewState.selected]);
      node.updateStyle(context, series);
      sendClickEvent(offset, node);
      oldHoverData = node;
    }

    if (node.notChild) {
      expandNode(node);
      return;
    }
    collapseNode(node);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    view.translationX += diff.dx;
    view.translationY += diff.dy;
    if (series.layout.optShowNode) {
      dataSet = _rBush.search(getViewPortRect());
    }
    notifyLayoutUpdate();
  }

  ///折叠一个节点
  void collapseNode(TreeData data) {
    if (data.notChild) {
      return;
    }
    List<TreeData> oldList = _rootNode.iterator();
    var option = getAnimation(LayoutType.update, oldList.length);
    if (option == null) {
      data.clear();
      _startLayout(_rootNode, false);
      updateNodeList(_rootNode);
      notifyLayoutUpdate();
      return;
    }

    final Set<TreeData> childSet = {};
    each(data.children, (p0, p1) {
      childSet.addAll(p0.iterator());
    });
    Map<TreeData, Offset> oldCenterMap = {};
    each(oldList, (p0, p1) {
      oldCenterMap[p0] = p0.center;
    });

    data.clear();
    _startLayout(_rootNode, false);
    Map<TreeData, Offset> newCenterMap = {};
    _rootNode.each((node, index, startNode) {
      newCenterMap[node] = node.center;
      return false;
    });
    var tween = ChartDoubleTween(option: option);
    tween.addStartListener(() {
      dataSet = oldList;
    });
    tween.addListener(() {
      var t = tween.value;
      each(oldList, (p0, p1) {
        if (childSet.contains(p0)) {
          p0.center = lerpOffset(oldCenterMap[p0]!, data.center, t);
        } else {
          p0.center = lerpOffset(oldCenterMap[p0]!, newCenterMap[p0]!, t);
        }
        var scale = childSet.contains(p0) ? 0 : 1;
        p0.attr.symbol.scale = lerpNum(1, scale, t);
      });
      notifyLayoutUpdate();
    });
    tween.addEndListener(() {
      updateNodeList(_rootNode);
      notifyLayoutUpdate();
    });
    tween.start(context, true);
  }

  ///展开一个节点
  void expandNode(TreeData clickNode) {
    var children = _childMap[clickNode];
    if (children == null || children.isEmpty) {
      ///没有孩子无法展开
      return;
    }
    final cOffset = clickNode.center;
    final Set<TreeData> childrenSet = {};
    each(children, (p0, p1) {
      childrenSet.addAll(p0.iterator());
    });

    Map<TreeData, Offset> oldCenterMap = {};

    _rootNode.each((node, index, startNode) {
      oldCenterMap[node] = node.center;
      return false;
    });
    var option = getAnimation(LayoutType.update, childrenSet.length + oldCenterMap.length);
    if (option == null) {
      clickNode.clear();
      clickNode.addAll(children);
      _startLayout(_rootNode, false);
      dataSet = _rootNode.iterator();
      _rBush.clear();
      _rBush.addAll(dataSet);
      notifyLayoutUpdate();
      return;
    }

    clickNode.clear();
    clickNode.addAll(children);
    _startLayout(_rootNode, false);

    Map<TreeData, Offset> newCenterMap = {};
    Map<TreeData, Size> newSizeMap = {};
    _rootNode.each((node, index, startNode) {
      newCenterMap[node] = node.center;
      newSizeMap[node] = node.size;
      return false;
    });
    var tween = ChartDoubleTween(option: option);
    tween.addStartListener(() {
      dataSet = _rootNode.iterator();
    });
    tween.addListener(() {
      var t = tween.value;
      _rootNode.each((node, index, startNode) {
        Offset offset = childrenSet.contains(node) ? cOffset : oldCenterMap[node]!;
        node.center = lerpOffset(offset, newCenterMap[node]!, t);
        double scale = childrenSet.contains(node) ? 0 : 1;
        node.attr.symbol.scale = lerpNum(scale, 1, t);
        return false;
      });
      notifyLayoutUpdate();
    });
    tween.addEndListener(() {
      updateNodeList(_rootNode);
      notifyLayoutUpdate();
    });
    tween.start(context, true);
  }

  @override
  TreeData? findData(Offset offset, [bool overlap = false]) {
    var result = _rBush.search2(Rect.fromCircle(center: offset, radius: 4));
    for (var node in result) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  @override
  Offset getTranslation() {
    return view.translation;
  }

  @override
  void dispose() {
    super.dispose();
    _rootNode = TreeData.empty;
    _childMap = {};
    _parentMap = {};
    _rBush.clear();
  }
}
