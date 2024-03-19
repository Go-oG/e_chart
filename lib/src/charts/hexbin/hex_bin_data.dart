import 'package:e_chart/e_chart.dart';

import 'package:flutter/material.dart';

class HexBinData extends RenderData<Offset> {
  HexBinData({super.id, super.name}) {
    hex = Hex.zero;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (scale <= 0) {
      return;
    }
    canvas.save();
    var offset = center;
    canvas.translate(offset.dx, offset.dy);
    if (rotate != 0) {
      canvas.rotate(rotate * StaticConfig.angleUnit);
    }
    if (scale != 1) {
      canvas.scale(scale);
    }
    var path = shapePath;
    if (path != null) {
      itemStyle.drawPath(canvas, paint, path);
      borderStyle.drawPath(canvas, paint, path);
    }
    canvas.restore();
    label.draw(canvas, paint);
  }

  @override
  bool contains(Offset offset) {
    var path = shapePath;
    if (path == null) {
      return false;
    }
    return path.contains(offset.translate(-center.dx, -center.dy));
  }

  @override
  void updateStyle(Context context, HexbinSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.updatePainter(style: series.getLabelStyle(context, this));
  }

  @override
  void updateLabelPosition(Context context, covariant ChartSeries series) {
    label.updatePainter(offset: center, align: Alignment.center);
  }

  double get rotate => extGetNull("rotate") ?? 0;

  set rotate(double v) => extSet("rotate", v);

  double get scale => extGetNull("scale") ?? 0;

  set scale(double v) => extSet("scale", v);

  Hex get hex => extGetNull("hex") ?? Hex(0, 0, 0);

  set hex(Hex v) => extSet("hex", v);

  Offset get center => extGetNull("center") ?? Offset.zero;

  set center(Offset v) => extSet("center", v);

  Path? get shapePath => extGetNull("path");

  set shapePath(Path? v) => extSet("path", v);

  @override
  Offset initAttr() => Offset.zero;
}
