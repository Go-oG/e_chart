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
  Fun3<TreeRenderNode, TreeRenderNode, num>? splitFun;

  RadialTreeLayout({
    this.rotateAngle = 0,
    this.sweepAngle = 360,
    this.useTidy = false,
    this.clockwise = true,
    this.splitFun,
    super.lineType = LineType.line,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void onLayout(TreeRenderNode rootNode, TreeLayoutParams params) {
    num width = params.width;
    num height = params.height;

    var center = Offset(params.series.center[0].convert(width), params.series.center[1].convert(height));
    int maxDeep = rootNode.findMaxDeep();
    num maxH = 0;
    for (int i = 1; i <= maxDeep; i++) {
      maxH += getLevelGap(i - 1, i);
    }
    List<TreeRenderNode> nodeList = [rootNode];
    List<TreeRenderNode> next = [];
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
      _layoutForTidy(params.series, rootNode, sweepAngle, radius);
    } else {
      _layoutForDendrogram(params.series, rootNode, sweepAngle, radius);
    }
    rootNode.each((node, index, startNode) {
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
    rootNode.x = center.dx;
    rootNode.y = center.dy;
  }

  void _layoutForDendrogram(TreeSeries series, TreeRenderNode root, num sweepAngle, num radius) {
    root.sort((p0, p1) => p1.height.compareTo(p0.height));
    var layout = D3DendrogramLayout(direction: Direction2.ttb, useCompactGap: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    var lp = TreeLayoutParams(series, sweepAngle.toDouble(), radius.toDouble());
    layout.onLayout(root, lp);
  }

  void _layoutForTidy(TreeSeries series, TreeRenderNode root, num sweepAngle, num radius) {
    var layout = D3TreeLayout(diff: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    var lp = TreeLayoutParams(series, sweepAngle.toDouble(), radius.toDouble());
    layout.onLayout(root, lp);
  }
}
