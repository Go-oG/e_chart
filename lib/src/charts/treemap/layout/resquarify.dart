import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'square.dart';

class ResquareLayout extends HierarchyLayout<TreeMapData,TreeMapSeries> {
  double rowsRatio = phi;

  @override
  void onLayout(TreeMapData data, var params) {
    Rect rect = params.boxBound;
    resquarify(data, rowsRatio, rect.left, rect.top, rect.right, rect.bottom);
  }

  static void resquarify(TreeMapData parent, double ratio, double x0, double y0, double x1, double y1) {
    List<Row> rows = [];
    Row row;
    List<TreeMapData> nodes = [];
    int i = 0;
    int j = -1;
    int n;
    int m = rows.length;
    double value = parent.value.toDouble();
    while (++j < m) {
      row = rows[j];
      nodes = row.children;
      row.value = 0;
      i = 0;
      for (n = nodes.length; i < n; ++i) {
        row.value += nodes[i].value;
      }
      if (row.dice) {
        SquareLayout.treemapDice(row, x0, y0, x1, value > 0 ? y0 += (y1 - y0) * row.value / value : y1);
      } else {
        SquareLayout.treemapSlice(row, x0, y0, value > 0 ? x0 += (x1 - x0) * row.value / value : x1, y1);
      }
      value -= row.value;
    }
  }
}
