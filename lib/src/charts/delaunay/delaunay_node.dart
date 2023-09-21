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
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawPath(canvas, paint, attr.toPath());
    borderStyle.drawPath(canvas, paint, attr.toPath());
  }

  @override
  void updateStyle(Context context, covariant DelaunaySeries series) {
    itemStyle = series.getAreaStyle(context, attr, attr.index, status);
    borderStyle = series.getBorderStyle(context, attr, attr.index, status);
  }
}
