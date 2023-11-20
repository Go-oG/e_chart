import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 缩进树布局
class IndentedLayout extends TreeLayout {
  Direction2 direction;

  IndentedLayout({
    this.direction = Direction2.ttb,
    super.lineType = LineType.before,
    super.smooth = 0,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void onLayout(TreeData data, HierarchyOption<TreeSeries> params) {
    var width = params.width;
    var height = params.height;
    Direction2 direction = this.direction;
    if (direction != Direction2.ltr && direction != Direction2.rtl && direction != Direction2.h) {
      direction = Direction2.ltr;
    }
    if (direction == Direction2.ltr || direction == Direction2.rtl) {
      _layoutTree(data, width, height, direction);
    } else {
      _layoutCenter(data, width, height);
    }
  }

  ///缩进树只支持stepAfter和StepBefore
  @override
  Path? onLayoutNodeLink(TreeData parent, TreeData child) {
    smooth = 0;
    Line line;
    if (lineType == LineType.after) {
      line = Line(Line.stepAfter([parent.center, child.center]));
    } else {
      line = Line(Line.stepBefore([parent.center, child.center]));
    }
    return line.toPath();
  }

  void _layoutCenter(TreeData root, num width, num height) {
    if (root.childCount <= 1) {
      _layoutTree(root, width, height, Direction2.ltr);
      return;
    }
    var leftRoot = TreeData(null, []);
    var rightRoot = TreeData(null, []);
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

  void _layoutTree(TreeData root, num width, num height, Direction2 direction) {
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

  @override
  bool get optShowNode => false;
}
