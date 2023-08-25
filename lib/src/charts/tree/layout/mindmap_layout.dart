import 'package:e_chart/e_chart.dart';

import '../node.dart';
import '../tree_layout.dart';
import 'compact_layout.dart';

///思维导图
class MindMapLayout extends TreeLayout {
  MindMapLayout({
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
    super.lineType = LineType.line,
    super.smooth = true,
    super.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.centerIsRoot = true,
    super.levelGapSize,
    super.nodeGapSize,
    super.nodeSize,
  });

  @override
  void onLayout2(TreeLayoutNode root) {
    if (root.childCount <= 1) {
      CompactLayout l = CompactLayout(
        levelAlign: Align2.start,
        direction: Direction2.ltr,
        gapFun: gapFun,
        levelGapFun: levelGapFun,
        sizeFun: sizeFun,
      );
      l.onLayout2(root);
      return;
    }
    TreeLayoutNode leftRoot = TreeLayoutNode(null, root.data);
    TreeLayoutNode rightRoot = TreeLayoutNode(null, root.data);
    int rightTreeSize = (root.childCount / 2).round();
    int i = 0;
    for (var node in root.children) {
      if (i < rightTreeSize) {
        leftRoot.add(node);
      } else {
        rightRoot.add(node);
      }
      i++;
    }

    CompactLayout leftLayout = CompactLayout(
      levelAlign: Align2.start,
      direction: Direction2.rtl,
      gapFun: gapFun,
      levelGapFun: levelGapFun,
      sizeFun: sizeFun,
    );
    leftLayout.onLayout2(leftRoot);

    CompactLayout rightLayout = CompactLayout(
      levelAlign: Align2.start,
      direction: Direction2.ltr,
      gapFun: gapFun,
      levelGapFun: levelGapFun,
      sizeFun: sizeFun,
    );
    rightLayout.onLayout2(rightRoot);

    root.children.clear();
    for (var element in leftRoot.children) {
      root.add(element);
    }
    for (var element in rightRoot.children) {
      root.add(element);
    }

    num tx = leftRoot.x - rightRoot.x;
    num ty = leftRoot.y - rightRoot.y;
    rightRoot.each((node, index, startNode) {
      node.x += tx;
      node.y += ty;
      return false;
    });
    root.x = leftRoot.x;
    root.y = leftRoot.y;
  }
}
