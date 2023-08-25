import 'package:e_chart/e_chart.dart';

import 'dice.dart';
import 'layout.dart';
import '../node.dart';
import 'slice.dart';

class SliceDiceLayout extends TreemapLayout {
  @override
  void onLayout2(TreeMapNode root, LayoutType type) {
    if (root.deep % 2 == 0) {
      SliceLayout.layoutChildren(boxBound, root.children);
    } else {
      DiceLayout.layoutChildren(boxBound, root.children);
    }
  }
}
