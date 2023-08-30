import 'dart:math' as math;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

///环形分布
class RadialTreeLayout extends TreeLayout {
  ///旋转角度
  num rotateAngle;

  ///扫过的角度
  num sweepAngle;

  ///是否顺时针
  bool clockwise;

  ///是否使用优化后的布局
  bool useTidy;

  ///只在 [useTidy]为true时使用
  Fun3<TreeLayoutNode, TreeLayoutNode, num>? splitFun;

  RadialTreeLayout({
    this.rotateAngle = 0,
    this.sweepAngle = 360,
    this.useTidy = false,
    this.clockwise = true,
    this.splitFun,
    super.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.centerIsRoot = true,
    super.lineType = LineType.line,
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
    super.levelGapSize,
    super.nodeGapSize,
    super.nodeSize,
  });

  @override
  void onLayout2(TreeLayoutNode root) {
    Offset center = Offset(this.center[0].convert(width), this.center[1].convert(height));
    int maxDeep = root.findMaxDeep();
    num maxH = 0;
    for (int i = 1; i <= maxDeep; i++) {
      maxH += getLevelGap(i - 1, i);
    }
    List<TreeLayoutNode> nodeList = [root];
    List<TreeLayoutNode> next = [];
    while (nodeList.isNotEmpty) {
      num v = 0;
      for (var n in nodeList) {
        Size size = n.size;
        v = math.max(v, size.longestSide);
        next.addAll(n.children);
      }
      maxH += v;
      nodeList = next;
      next = [];
    }
    num radius = maxH / 2;
    if (useTidy) {
      _layoutForTidy(context, root, sweepAngle, radius);
    } else {
      _layoutForDendrogram(context, root, sweepAngle, radius);
    }
    root.each((node, index, startNode) {
      Offset c;
      if (clockwise) {
        c = circlePoint(node.y, node.x + rotateAngle, center);
      } else {
        c = circlePoint(node.y, sweepAngle - (node.x + rotateAngle), center);
      }
      node.x = c.dx;
      node.y = c.dy;
      return false;
    });
    root.x = center.dx;
    root.y = center.dy;
  }

  void _layoutForDendrogram(Context context, TreeLayoutNode root, num sweepAngle, num radius) {
    root.sort((p0, p1) => p1.height.compareTo(p0.height));
    D3DendrogramLayout layout = D3DendrogramLayout(direction: Direction2.ttb, diff: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.boxBound = Rect.fromLTWH(0, 0, sweepAngle.toDouble(), radius.toDouble());
    layout.onLayout2(root);
  }

  void _layoutForTidy(Context context, TreeLayoutNode root, num sweepAngle, num radius) {
    D3TreeLayout layout = D3TreeLayout(diff: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.boxBound = Rect.fromLTWH(0, 0, sweepAngle.toDouble(), radius.toDouble());
    layout.onLayout2(root);
  }
}
