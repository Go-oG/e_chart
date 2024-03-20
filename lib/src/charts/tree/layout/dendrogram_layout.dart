import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///生态树布局
class DendrogramLayout extends TreeLayout {
  Direction2 direction;

  DendrogramLayout({
    this.direction = Direction2.ttb,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.lineType,
    super.nodeGapSize,
    super.smooth,
  });

  @override
  void onLayout(TreeData data, HierarchyOption<TreeSeries> params) {
    List<num> yList = List.filled(data.height + 1, 0);
    for (int i = 1; i <= data.height; i++) {
      num levelGap = getLevelGap(i - 1, i);
      yList[i] = levelGap + yList[i - 1];
    }
    if (direction != Direction2.v && direction != Direction2.h) {
      return _layoutNode(data, direction, yList);
    }
    int c = data.childCount;
    if (c <= 1) {
      Direction2 d = direction == Direction2.v ? Direction2.ttb : Direction2.ltr;
      return _layoutNode(data, d, yList);
    }
    var leftNode = TreeData(null, []);
    var rightNode = TreeData(null, []);
    int middle = c ~/ 2;
    List<TreeData> cd = List.from(data.children);
    data.clear();
    each(cd, (node, i) {
      if (i <= middle) {
        leftNode.add(node);
      } else {
        rightNode.add(node);
      }
    });

    ///重新计算树的深度和高度
    leftNode.setDeep(0, true);
    leftNode.computeHeight();

    rightNode.setDeep(0, true);
    rightNode.computeHeight(0);
    if (direction == Direction2.v) {
      _layoutNode(leftNode, Direction2.btt, yList);
      _layoutNode(rightNode, Direction2.ttb, yList);
    } else {
      _layoutNode(leftNode, Direction2.rtl, yList);
      _layoutNode(rightNode, Direction2.ltr, yList);
    }

    bool b = leftNode.childCount > rightNode.childCount;
    if (b) {
      ///将right 平移到left
      num dx = leftNode.x - rightNode.x;
      num dy = leftNode.y - rightNode.y;
      rightNode.translate(dx, dy);
    } else {
      ///将left 平移到right
      num dx = rightNode.x - leftNode.x;
      num dy = rightNode.y - leftNode.y;
      leftNode.translate(dx, dy);
    }

    ///还原节点层次关系
    data.size = rightNode.size;
    data.x = b ? leftNode.x : rightNode.x;
    data.y = b ? leftNode.y : rightNode.y;
    for (var node in [...leftNode.children, ...rightNode.children]) {
      node.parent = null;
      data.add(node);
    }

    ///还原树的高度和深度
    data.setDeep(0, false);
    data.setHeight(max(leftNode.height, rightNode.height), false);
  }

  void _layoutNode(TreeData root, Direction2 direction, List<num> yList) {
    if (direction == Direction2.v || direction == Direction2.h) {
      throw FlutterError('该方法不支持 Direction2.v 和Direction2.h');
    }
    bool v = direction == Direction2.ttb || direction == Direction2.btt;
    List<TreeData> leafList = root.leaves();

    root.each((node, index, startNode) {
      if (v) {
        node.y = yList[node.deep];
      } else {
        node.x = yList[node.deep];
      }
      return false;
    });

    ///处理X轴方向的位置
    num offset = 0;
    TreeData? preNode;
    List<TreeData> preLeafList = [];
    Set<TreeData> preLeafSet = {};
    Map<TreeData, TreeData> rightMap = {};
    Map<TreeData, TreeData> leftMap = {};
    for (var node in leafList) {
      rightMap[node] = node;
      leftMap[node] = node;
      Size size = node.size;
      if (v) {
        node.x = offset + size.width / 2;
        offset += size.width + getNodeGap(preNode ?? node, node).dx;
      } else {
        node.y = offset + size.height / 2;
        offset += size.height + getNodeGap(preNode ?? node, node).dy;
      }
      if (node.parent != null && (node.parent!.height - node.height).abs() == 1 && !preLeafSet.contains(node.parent!)) {
        preLeafList.add(node.parent!);
      }
    }
    List<TreeData> nextLeafList = [];

    while (preLeafList.isNotEmpty) {
      preLeafSet = {};
      for (var node in preLeafList) {
        TreeData right, left;
        right = rightMap[node.lastChild] ?? node.leafRight();
        left = leftMap[node.firstChild] ?? node.leafLeft();
        rightMap[node] = right;
        leftMap[node] = left;

        if (v) {
          node.x = (right.x + left.x) / 2;
        } else {
          node.y = (right.y + left.y) / 2;
        }
        var parent = node.parent;
        if (parent != null && (parent.height - node.height).abs() == 1 && !preLeafSet.contains(parent)) {
          nextLeafList.add(parent);
          preLeafSet.add(parent);
        }
      }
      preLeafList = nextLeafList;
      nextLeafList = [];
    }
    if (direction == Direction2.btt) {
      root.bottom2Top();
    } else if (direction == Direction2.rtl) {
      root.right2Left();
    }
  }
}
