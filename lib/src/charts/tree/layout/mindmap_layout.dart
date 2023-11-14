import 'package:e_chart/e_chart.dart';

///思维导图
class MindMapLayout extends TreeLayout {
  MindMapLayout({
    super.gapFun,
    super.levelGapFun,
    super.lineType = LineType.line,
    super.smooth = 0.5,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void onLayout(TreeData rootNode, TreeLayoutParams params) {
    if (rootNode.childCount <= 1) {
      CompactLayout(
        levelAlign: Align2.start,
        direction: Direction2.ltr,
        gapFun: gapFun,
        levelGapFun: levelGapFun,
      ).onLayout(rootNode, params);
      return;
    }
    var leftRoot = TreeData(null, []);
    var rightRoot = TreeData(null, []);
    int rightTreeSize = (rootNode.childCount / 2).round();
    int i = 0;
    for (var node in rootNode.children) {
      node.parent=null;
      if (i < rightTreeSize) {
        leftRoot.add(node);
      } else {
        rightRoot.add(node);
      }
      i++;
    }

    var leftLayout =
        CompactLayout(levelAlign: Align2.start, direction: Direction2.rtl, gapFun: gapFun, levelGapFun: levelGapFun);
    leftLayout.onLayout(leftRoot, params);

    var rightLayout =
        CompactLayout(levelAlign: Align2.start, direction: Direction2.ltr, gapFun: gapFun, levelGapFun: levelGapFun);
    rightLayout.onLayout(rightRoot, params);

    rootNode.children.clear();
    for (var element in leftRoot.children) {
      element.parent=null;
      rootNode.add(element);
    }
    for (var element in rightRoot.children) {
      element.parent=null;
      rootNode.add(element);
    }

    num tx = leftRoot.x - rightRoot.x;
    num ty = leftRoot.y - rightRoot.y;
    rightRoot.each((node, index, startNode) {
      node.x += tx;
      node.y += ty;
      return false;
    });
    rootNode.x = leftRoot.x;
    rootNode.y = leftRoot.y;
  }
}
