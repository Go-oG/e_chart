import 'dart:ui';
import 'package:e_chart/src/core/context.dart';
import 'package:e_chart/src/core/render/ccanvas.dart';
import 'package:flutter/material.dart';
import '../../component/style/index.dart';
import '../../core/data_node.dart';
import '../../model/delaunay/d_shape.dart';
import 'delaunay_series.dart';

class DelaunayNode extends DataNode<DShape, List<Offset>> {
  DelaunayNode(
    List<Offset> data,
    int dataIndex,
    int groupIndex,
    DShape attr,
  ) : super.empty(data, dataIndex, groupIndex, attr);

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var p = attr.path ?? attr.toPath();
    itemStyle.drawPath(canvas, paint, p);
    borderStyle.drawPath(canvas, paint, p);
  }

  @override
  void updateStyle(Context context, covariant DelaunaySeries series) {
    itemStyle = series.getAreaStyle(context, attr, attr.index, status);
    borderStyle = series.getBorderStyle(context, attr, attr.index, status);
  }
}
