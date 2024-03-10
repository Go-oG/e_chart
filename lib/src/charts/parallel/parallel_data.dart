import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/layout/layout_result.dart';
import 'package:flutter/material.dart';

class ParallelData extends RenderGroupData<ParallelChildData> {
  bool connectNull = false;
  ParallelData(
    super.data, {
    super.id,
    super.name,
    this.connectNull = false,
  });
}

class ParallelChildData extends RenderChildData<dynamic,ParallelData,Offset> {
  ParallelChildData(super.data, {super.id, super.name});

  @override
  bool contains(Offset offset) {
    if (data == null) {
      return false;
    }
    var p = path;
    if (p != null) {
      return p.contains(offset);
    }
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var p = path;
    if (p == null) {
      return;
    }
    borderStyle.drawPath(canvas, paint, p, drawDash: false);
  }

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    symbol?.draw(canvas, paint, center);
  }

  @override
  void updateStyle(Context context, covariant ParallelSeries series) {
    var old = borderStyle;
    itemStyle = AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, this, parent);
    label.style = series.getLabelStyle(context, this, parent);
    symbol = series.getSymbol(this, parent);
    if (old.changeEffect(borderStyle)) {
      updatePath();
    }
  }

  void updatePath() {
    var points = lines;
    if (points.length < 2) {
      path = null;
    } else {
      path = borderStyle.buildPath(points);
    }
  }

  List<Offset> get lines => extGetNull("lines") ?? [];
  set lines(List<Offset> v) => extSet("lines", v);

  Path? get path => extGetNull("path");

  set path(Path? p) => extSet("path", p);

  @override
  Offset initAttr()=>Offset.zero;

}
