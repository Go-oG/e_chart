import 'package:e_chart/src/charts/treemap/treemap_data.dart';

import '../../common/hierarchy/hierarchy_layout.dart';
import '../treemap_series.dart';

class EmptyTreemapLayout extends HierarchyLayout<TreeMapData,TreeMapSeries> {
  static final EmptyTreemapLayout layer = EmptyTreemapLayout();

  @override
  void onLayout(TreeMapData data, var params) {}
}
