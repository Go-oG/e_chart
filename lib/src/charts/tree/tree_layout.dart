import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class TreeLayout extends Disposable{
  ///连接线的类型(某些布局只支持某些特定类型)
  LineType lineType;

  ///是否平滑连接线
  num smooth;

  ///节点之间的间距函数
  Offset? nodeGapSize;
  Fun3<TreeData, TreeData, Offset>? gapFun;

  ///节点之间的层级间距函数优先级：fun> levelGapSize
  num? levelGapSize;
  Fun3<int, int, num>? levelGapFun;

  TreeLayout({
    this.lineType = LineType.line,
    this.smooth = 0,
    this.nodeGapSize,
    this.gapFun,
    this.levelGapSize,
    this.levelGapFun,
  });

  void onLayout(TreeData rootNode, TreeLayoutParams params);

  Path? onLayoutNodeLink(TreeData parent, TreeData child) {
    Line line = Line([parent.center, child.center]);
    List<Offset> ol = [];
    if (lineType == LineType.step) {
      ol = line.step();
    } else if (lineType == LineType.before) {
      ol = line.stepBefore();
    } else if (lineType == LineType.after) {
      ol = line.stepAfter();
    } else {
      ol = [parent.center, child.center];
    }
    return Line(ol, smooth: smooth).toPath();
  }

  ///========普通函数=============
  Offset getNodeGap(TreeData node1, TreeData node2) {
    Offset? offset = gapFun?.call(node1, node2) ?? nodeGapSize;
    if (offset != null) {
      return offset;
    }
    return const Offset(8, 8);
  }

  double getLevelGap(int level1, int level2) {
    if (levelGapFun != null) {
      return levelGapFun!.call(level1, level2).toDouble();
    }
    if (levelGapSize != null) {
      return levelGapSize!.toDouble();
    }
    return 24;
  }

  bool get optShowNode=>true;

}

class TreeLayoutParams {
  final TreeSeries series;
  final double width;
  final double height;

  TreeLayoutParams(this.series, this.width, this.height);
}
