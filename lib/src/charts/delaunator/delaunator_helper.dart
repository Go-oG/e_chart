import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'delaunator_node.dart';
import 'delaunator_series.dart';

class DelaunatorHelper extends LayoutHelper2<DelaunatorNode, DelaunatorSeries> {
  Path path = Path();

  DelaunatorHelper(super.context, super.view, super.series);

  @override
  void onLayout(LayoutType type) {
    path = Path();
    List<Offset> ol = List.from(series.data.map((e) => e.offset));
    var de = Delaunator(ol);
    de.eachTriangle((p0, p1, p2, index) {
      path.moveTo2(p0);
      path.lineTo2(p1);
      path.lineTo2(p2);
      path.close();
    });

  }
}
