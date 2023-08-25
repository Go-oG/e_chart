import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../node.dart';
import '../tree_layout.dart';

/// 缩进树布局
class IndentedLayout extends TreeLayout {
  Direction2 direction;

  IndentedLayout({
    this.direction = Direction2.ttb,
    super.lineType = LineType.stepBefore,
    super.smooth=false,
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
    super.center=const [SNumber.percent(0), SNumber.percent(0)],
    super.centerIsRoot,
    super.levelGapSize,
    super.nodeGapSize,
    super.nodeSize,
  });

  @override
  void onLayout2(TreeLayoutNode root) {
    Direction2 direction = this.direction;
    if (direction != Direction2.ltr && direction != Direction2.rtl && direction != Direction2.h) {
      direction = Direction2.ltr;
    }
    if (direction == Direction2.ltr || direction == Direction2.rtl) {
      _layoutTree(root, width, height, direction);
    } else {
      _layoutCenter(root, width, height);
    }
  }

  ///缩进树只支持stepAfter和StepBefore
  @override
  Path? getPath(TreeLayoutNode parent, TreeLayoutNode child, [List<double>? dash]) {
    smooth=false;
    Line line = Line([parent.center, child.center]);
    if (lineType == LineType.stepAfter) {
      line = Line(line.stepAfter(), dashList: dash);
    } else {
      line = Line(line.stepBefore(), dashList: dash);
    }
    return line.toPath(false);
  }

  void _layoutCenter(TreeLayoutNode root, num width, num height) {
    if (root.childCount <= 1) {
      _layoutTree(root, width, height, Direction2.ltr);
      return;
    }
    TreeLayoutNode leftRoot = TreeLayoutNode(null, root.data);
    TreeLayoutNode rightRoot = TreeLayoutNode(null, root.data);
    int i = 0;
    for (var element in root.children) {
      if (i % 2 == 0) {
        leftRoot.add(element);
      } else {
        rightRoot.add(element);
      }
      i++;
    }
    _layoutTree(leftRoot, width, height, Direction2.rtl);
    _layoutTree(rightRoot, width, height, Direction2.ltr);

    Offset leftOffset = leftRoot.center;
    Offset rightOffset = rightRoot.center;
    Offset center = Offset(width / 2, 0);
    double tx = center.dx - leftOffset.dx;
    double ty = center.dy - leftOffset.dy;
    leftRoot.translate(tx, ty);

    tx = center.dx - rightOffset.dx;
    ty = center.dy - rightOffset.dy;
    rightRoot.translate(tx, ty);

    root.clear();
    for (var node in leftRoot.children) {
      root.add(node);
    }
    for (var node in rightRoot.children) {
      root.add(node);
    }
    root.x = center.dx;
    root.y = center.dy;
  }

  void _layoutTree(TreeLayoutNode root, num width, num height, Direction2 direction) {
    double topOffset = 0;
    root.eachBefore((p0, p1, p2) {
      Size size = p0.size;
      Size parentSize = p0.parent == null ? Size.zero : p0.parent!.size;
      //节点之间的水平间距
      Offset gap = getNodeGap(p0.parent ?? p0, p0);
      num parentX = p0.parent == null ? 0 : p0.parent!.x;
      double g = m.max(0, gap.dx);
      g = (parentSize.width / 2 + g + size.width / 2);
      double levelG = getLevelGap(m.max(p0.deep - 1, 0), p0.deep);
      p0.x = (direction == Direction2.ltr) ? parentX + g : parentX - g;
      p0.y = topOffset + size.height / 2;
      topOffset += size.height + levelG;
      return false;
    });
  }
}
