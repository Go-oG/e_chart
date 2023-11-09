import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ParallelData extends RenderData<Offset> {
  List<ParallelChildData> data;
  bool connectNull = false;

  ParallelData(
    this.data, {
    super.id,
    super.name,
    this.connectNull = false,
  });

  @override
  bool contains(Offset offset) {
    for (var c in data) {
      if (c.contains(offset)) {
        return true;
      }
    }
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    each(data, (p0, p1) {
      p0.onDraw(canvas, paint);
    });
  }

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    each(data, (p0, p1) {
      p0.onDrawSymbol(canvas, paint);
    });
  }

  @override
  void updateStyle(Context context, covariant ParallelSeries series) {
    each(data, (p0, p1) {
      p0.updateStyle(context, series);
    });
  }
}

class ParallelChildData extends RenderData<Offset> {
  dynamic data;

  ParallelChildData(this.data, {super.id, super.name});

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
    symbol?.draw(canvas, paint, point);
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

  ParallelData get parent => extGet("parent");

  set parent(ParallelData p) => extSet("parent", p);

  ChartSymbol? get symbol => extGetNull("symbol");

  set symbol(ChartSymbol? s) => extSet("symbol", s);

  Offset get point => extGet("point");

  set point(Offset p) => extSet("point", p);

  List<Offset> get lines => extGetNull("lines") ?? [];

  set lines(List<Offset> v) => extSet("lines", v);

  Path? get path => extGetNull("path");

  set path(Path? p) => extSet("path", p);

  bool get dataIsNull => data == null;
}
