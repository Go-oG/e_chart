import 'package:e_chart/e_chart.dart';

class SliceDiceLayout extends TreemapLayout {
  @override
  void onLayout2(TreeMapData root, LayoutType type) {
    if (root.deep % 2 == 0) {
      SliceLayout.layoutChildren(boxBound, root.children);
    } else {
      DiceLayout.layoutChildren(boxBound, root.children);
    }
  }
}
