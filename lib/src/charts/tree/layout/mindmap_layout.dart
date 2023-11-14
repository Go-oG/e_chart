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
  void onLayout(TreeData data, HierarchyOption<TreeSeries> params) {
    if (data.childCount <= 1) {
      CompactLayout(
        levelAlign: Align2.start,
        direction: Direction2.ltr,
        gapFun: gapFun,
        levelGapFun: levelGapFun,
      ).onLayout(data, params);
      return;
    }
    var leftRoot = TreeData(null, []);
    var rightRoot = TreeData(null, []);
    int rightTreeSize = (data.childCount / 2).round();
    int i = 0;
    for (var node in data.children) {
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

    data.children.clear();
    for (var element in leftRoot.children) {
      element.parent=null;
      data.add(element);
    }
    for (var element in rightRoot.children) {
      element.parent=null;
      data.add(element);
    }

    num tx = leftRoot.x - rightRoot.x;
    num ty = leftRoot.y - rightRoot.y;
    rightRoot.each((node, index, startNode) {
      node.x += tx;
      node.y += ty;
      return false;
    });
    data.x = leftRoot.x;
    data.y = leftRoot.y;
  }
}
