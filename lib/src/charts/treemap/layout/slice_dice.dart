import 'package:e_chart/e_chart.dart';

class SliceDiceLayout extends HierarchyLayout<TreeMapData, TreeMapSeries> {
  @override
  void onLayout(TreeMapData data, var params) {
    if (data.deep % 2 == 0) {
      SliceLayout.layoutChildren(params.boxBound, data.children);
    } else {
      DiceLayout.layoutChildren(params.boxBound, data.children);
    }
  }
}
