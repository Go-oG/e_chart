import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class TreeHelper extends LayoutHelper2<TreeRenderNode, TreeSeries> {
  TreeHelper(super.context, super.view, super.series);

  ///保存数据和节点之间的映射关系，以便在O(1)时间中处理数据
  Map<TreeData, TreeRenderNode> _nodeMap = {};

  TreeRenderNode _rootNode = TreeRenderNode(null, TreeData.empty, 0, TreeAttr.of());

  TreeRenderNode get rootNode => _rootNode;

  final RBush<TreeRenderNode> _rBush = RBush(
    (p0) => p0.center.dx - p0.size.width / 2,
    (p0) => p0.center.dy - p0.size.height / 2,
    (p0) => p0.center.dx + p0.size.width / 2,
    (p0) => p0.center.dy + p0.size.height / 2,
  );

  void updateShowNodeList() {
    nodeList = _rBush.search(getViewPortRect());
  }

  @override
  void onLayout(LayoutType type) {
    _nodeMap = {};
    int i = 0;
    var root = toTree<TreeData, TreeAttr, TreeRenderNode>(series.data, (p0) => p0.children, (p0, p1) {
      var node = TreeRenderNode(p0, p1, i, TreeAttr.of());
      node.attr.symbol = series.getSymbol(context, node);
      i += 1;
      _nodeMap[p1] = node;
      node.updateStyle(context, series);
      node.size = node.attr.symbol.size;
      return node;
    });
    _startLayout(root);
    _rootNode = root;
    _rBush.clear();
    _rBush.addAll(root.iterator());
    updateShowNodeList();
  }

  void _startLayout(TreeRenderNode root) {
    ///计算树的深度和高度
    root.setDeep(0);
    root.computeHeight();

    ///开始布局
    series.layout.onLayout(root, TreeLayoutParams(series, width, height));

    ///布局完成计算偏移量并更新节点
    double x = series.center[0].convert(width);
    double y = series.center[1].convert(height);

    ///布局完成后，需要再次更新节点位置和大小
    translationX = translationY = 0;

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
    var node = findNode(offset);

    if (node == null) {
      var oh = oldHoverNode;
      oldHoverNode = null;
      if (oh == null) {
        return;
      }
      oh.removeStates([ViewState.hover, ViewState.selected]);
      oh.updateStyle(context, series);
      sendHoverEndEvent(oh);
      notifyLayoutUpdate();
      return;
    }

    if (node != oldHoverNode) {
      var oh = oldHoverNode;
      if (oh != null) {
        oldHoverNode = null;
        oh.removeStates([ViewState.hover, ViewState.selected]);
        oh.updateStyle(context, series);
        sendHoverEndEvent(oh);
      }
      node.addStates([ViewState.hover, ViewState.selected]);
      node.updateStyle(context, series);
      sendClickEvent(offset, node);
      oldHoverNode = node;
    }

    if (node.notChild) {
      expandNode(node);
      return;
    }
    collapseNode(node);
  }

  ///折叠一个节点
  void collapseNode(TreeRenderNode node) {
    var clickNode = node;
    if (clickNode.notChild) {
      notifyLayoutUpdate();
      return;
    }

    ///存储旧位置
    Map<TreeData, Offset> oldPositionMap = {};
    Map<TreeData, Size> oldSizeMap = {};
    _rootNode.each((node, index, startNode) {
      oldPositionMap[node.data] = node.center;
      oldSizeMap[node.data] = node.size;
      return false;
    });

    ///先保存折叠节点的子节点
    List<TreeRenderNode> removedNodes = List.from(clickNode.children);
    clickNode.clear();

    ///移除其父节点
    each(removedNodes, (p0, p1) {
      p0.parent = null;
    });

    ///移除节点后-重新布局位置并记录
    ///这里先不更新显示节点
    _startLayout(_rootNode);
    List<TreeRenderNode> nodeSet=List.from(nodeList);
    var rect=getViewPortRect();
    _rootNode.each((node, index, startNode){
      if(rect.overlaps(Rect.fromCircle(center: node.center, radius: node.size.shortestSide/2))){
        nodeSet.add(node);
      }
      return false;
    });
    nodeList=nodeSet;

    Map<TreeData, Offset> positionMap = {};
    Map<TreeData, Size> sizeMap = {};
    _rootNode.each((node, index, startNode) {
      positionMap[node.data] = node.center;
      sizeMap[node.data] = node.size;
      return false;
    });

    ///为了保证动画正常，需要补齐以前节点的位置
    each(removedNodes, (node, i) {
      node.each((cNode, index, startNode) {
        positionMap[cNode.data] = clickNode.center;
        sizeMap[cNode.data] = Size.zero;
        return false;
      });
    });

    ///还原移除的节点
    for (var n in removedNodes) {
      clickNode.add(n);
    }

    doAnimator(_rootNode, oldPositionMap, positionMap, oldSizeMap, sizeMap, () {
      ///动画结束后，重新移除节点
      clickNode.clear();
      each(removedNodes, (p0, p1) {
        p0.parent = null;
      });

      ///动画结束更新区域
      _rBush.clear();
      _rBush.addAll(_rootNode.iterator());
      updateShowNodeList();
      notifyLayoutEnd();
    });
  }

  ///展开一个节点
  void expandNode(TreeRenderNode node) {
    var data = node.data;
    var clickNode = _nodeMap[data]!;
    if (clickNode.hasChild || data.children.isEmpty) {
      notifyLayoutUpdate();
      return;
    }

    var animation=getAnimation(LayoutType.update);
    if (animation==null) {
      for (var c in data.children) {
        clickNode.add(_nodeMap[c]!);
      }
      _startLayout(_rootNode);
      _rBush.clear();
      _rBush.addAll(_rootNode.iterator());
      updateShowNodeList();

      notifyLayoutUpdate();
      return;
    }

    ///记录原始的大小和位置
    Map<TreeData, Offset> oldPositionMap = {};
    Map<TreeData, Size> oldSizeMap = {};
    _rootNode.each((node, index, startNode) {
      oldPositionMap[node.data] = node.center;
      oldSizeMap[node.data] = node.size;
      return false;
    });

    ///添加节点并保存当前点击节点的位置
    for (var c in data.children) {
      TreeRenderNode cNode = _nodeMap[c]!;
      clickNode.add(cNode);
    }
    Offset oldOffset = clickNode.center;

    ///二次测量位置
    _startLayout(_rootNode);
    _rBush.clear();
    _rBush.addAll(_rootNode.iterator());
    updateShowNodeList();

    Map<TreeData, Offset> positionMap = {};
    Map<TreeData, Size> sizeMap = {};
    _rootNode.each((node, index, startNode) {
      if (!oldPositionMap.containsKey(node.data)) {
        ///如果是新增节点
        oldPositionMap[node.data] = oldOffset;
        oldSizeMap[node.data] = Size.zero;
      }
      positionMap[node.data] = node.center;
      sizeMap[node.data] = node.size;
      return false;
    });
    doAnimator(_rootNode, oldPositionMap, positionMap, oldSizeMap, sizeMap);
  }

  void doAnimator(
    TreeRenderNode root,
    Map<TreeData, Offset> oldPositionMap,
    Map<TreeData, Offset> positionMap,
    Map<TreeData, Size> oldSizeMap,
    Map<TreeData, Size> sizeMap, [
    VoidCallback? endCallback,
  ]) {
    var animation = getAnimation(LayoutType.update);
    if (animation == null) {
      root.each((node, index, startNode) {
        Offset end = positionMap[node.data] ?? node.center;
        node.x = end.dx;
        node.y = end.dy;
        node.size = sizeMap[node.data] ?? node.size;
        return false;
      });
      notifyLayoutUpdate();
      return;
    }

    var tween = ChartDoubleTween(option: animation);
    tween.addListener(() {
      double v = tween.value;
      root.each((node, index, startNode) {
        Offset begin = oldPositionMap[node.data] ?? node.center;
        Offset end = positionMap[node.data] ?? node.center;
        Offset p = Offset.lerp(begin, end, v)!;
        node.x = p.dx;
        node.y = p.dy;
        Size beginSize = oldSizeMap[node.data] ?? Size.zero;
        Size endSize = sizeMap[node.data] ?? node.size;
        node.size = Size.lerp(beginSize, endSize, v)!;
        return false;
      });
      notifyLayoutUpdate();
    });
    if (endCallback != null) {
      tween.addEndListener(endCallback);
    }
    tween.start(context, true);
  }

  @override
  TreeRenderNode? findNode(Offset offset, [bool overlap = false]) {
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
}
