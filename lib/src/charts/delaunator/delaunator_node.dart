import 'dart:ui';

import 'package:e_chart/src/core/context.dart';

import 'package:e_chart/src/core/render/ccanvas.dart';

import 'package:e_chart/src/core/series/series.dart';

import '../../core/data_node.dart';
import 'delaunator_series.dart';

class DelaunatorNode extends DataNode<List<Offset>, DelaunatorData> {


  DelaunatorNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  @override
  bool contains(Offset offset) {
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {

  }

  @override
  void updateStyle(Context context, covariant ChartSeries series) {}
}
