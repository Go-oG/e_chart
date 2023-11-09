import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarData extends RenderData<Path> {
  static final Path emptyPath = Path();
  List<RadarChildData> data;

  double scale = 1;
  Offset center = Offset.zero;

  RadarData(
    this.data, {
    super.id,
    super.name,
  }) : super.attr(emptyPath);

  Path? get pathOrNull {
    if (attr == emptyPath) {
      return null;
    }
    return attr;
  }

  Path get path {
    if (attr == emptyPath) {
      attr = buildPath();
    }
    return attr;
  }

  void updatePath() {
    attr = buildPath();
  }

  Path buildPath() {
    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      var node = data[i];
      if (i == 0) {
        path.moveTo(node.attr.dx, node.attr.dy);
      } else {
        path.lineTo(node.attr.dx, node.attr.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!show) {
      return;
    }

    Path? path = pathOrNull;
    if (path != null) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
      itemStyle.drawPath(canvas, paint, path);
      borderStyle.drawPath(canvas, paint, path, drawDash: true);
      canvas.restore();
    }

    each(data, (node, p1) {
      node.onDraw(canvas, paint);
    });
  }

  @override
  void updateStyle(Context context, covariant RadarSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.style = LabelStyle.empty;
    label.updatePainter();
  }
}

class RadarChildData extends RenderData<Offset> {
  late RadarData parent;
  num value;
  ChartSymbol? symbol;

  RadarChildData(
    this.value, {
    super.id,
    super.name,
  }) : super.attr(Offset.zero);

  @override
  bool contains(Offset offset) {
    var sb = symbol;
    if (sb == null) {
      return false;
    }
    return sb.contains(attr, offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var sb = symbol;
    if (sb == null) {
      return;
    }
    sb.draw(canvas, paint, attr);
  }

  @override
  void updateStyle(Context context, covariant RadarSeries series) {
    symbol = series.getSymbol(context, this);
  }
}
