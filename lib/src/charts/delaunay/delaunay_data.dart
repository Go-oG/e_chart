import 'dart:ui';
import 'package:e_chart/src/core/context.dart';
import 'package:e_chart/src/core/render/ccanvas.dart';
import 'package:flutter/material.dart';
import '../../core/render/render_data.dart';
import '../../model/delaunay/d_shape.dart';
import 'delaunay_series.dart';

class DelaunayData extends RenderData<DShape> {
  late DShape shape;
  DelaunayData(this.shape);

  @override
  bool contains(Offset offset) {
    return shape.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var p = shape.path ?? shape.toPath();
    itemStyle.drawPath(canvas, paint, p);
    borderStyle.drawPath(canvas, paint, p);
  }

  @override
  void updateStyle(Context context, covariant DelaunaySeries series) {
    itemStyle = series.getAreaStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
  }

  @override
  DShape initAttr()=>shape;
}
