import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class FunnelNode extends DataNode<Polygon, ItemData> {
  final int index;
  final ItemData? preData;

  double scale = 1;
  Offset center = Offset.zero;

  FunnelNode(
    this.index,
    this.preData,
    ItemData data,
    int dataIndex,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(data, dataIndex, 0, Polygon.zero, itemStyle, borderStyle, labelStyle);

  @override
  set attr(Polygon a) {
    super.attr = a;
    if (a.points.length < 4) {
      center=Offset.zero;
      return;
    }
    Offset p0 = attr.points[0];
    Offset p1 = attr.points[1];
    Offset p3 = attr.points[3];
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
    center = Offset(centerX, centerY);
  }

  @override
  void updateLabelPosition(Context context, FunnelSeries series) {
    var style = label.style;
    Offset p0 = attr.points[0];
    Offset p1 = attr.points[1];
    Offset p2 = attr.points[2];
    double centerX = center.dx;
    double centerY = center.dy;
    double topW = (p1.dx - p0.dx).abs();
    ChartAlign align = series.getLabelAlign(data, status);
    double x = centerX + align.align.x * topW / 2;
    double y = centerY + align.align.y * (p1.dy - p2.dy).abs() / 2;
    if (!align.inside) {
      double lineWidth = (style.guideLine?.length ?? 0).toDouble();
      List<num> lineGap = (style.guideLine?.gap ?? [0, 0]);
      if (series.direction == Direction.vertical) {
        int dir = align.align.x > 0 ? 1 : -1;
        x += dir * (lineWidth + lineGap[0]);
      } else {
        int dir = align.align.y > 0 ? 1 : -1;
        y += dir * (lineWidth + lineGap[1]);
      }
    }
    Offset offset = Offset(x, y);
    Alignment textAlign = toInnerAlign(align.align);
    if (!align.inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    label.updatePainter(text: data.name ?? DynamicText.empty, offset: offset, align: textAlign);
    labelLine = computeLabelLineOffset(context, series, label.offset) ?? [];
  }

  List<Offset>? computeLabelLineOffset(Context context, FunnelSeries series, Offset? textOffset) {
    ChartAlign align = series.getLabelAlign(data, status);
    if (align.inside || textOffset == null) {
      return null;
    }

    LabelStyle style = label.style;
    if (!style.show) {
      return null;
    }
    GuideLine? guideLine = style.guideLine;
    double lineWidth = 0;
    List<num> gap = [0, 0];
    if (guideLine != null) {
      lineWidth = guideLine.length.toDouble();
      gap = guideLine.gap;
    }

    double x1, y1, x2, y2;
    if (series.direction == Direction.vertical) {
      int dir = align.align.x > 0 ? -1 : 1;
      x2 = textOffset.dx + dir * gap[0];
      x1 = x2 + dir * lineWidth;
      y1 = y2 = textOffset.dy;
    } else {
      x1 = x2 = textOffset.dx;
      int dir = align.align.y > 0 ? -1 : 1;
      y2 = textOffset.dy + dir * gap[1];
      y1 = y2 + dir * lineWidth;
    }
    return [Offset(x1, y1), Offset(x2, y2)];
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    bool need = scale != 1;
    if (need) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
    }
    itemStyle.drawPolygon(canvas, paint, attr);
    borderStyle.drawPolygon2(canvas, paint, attr);
    if (!label.notDraw) {
      List<Offset>? ol = labelLine;
      label.style.guideLine?.style.drawPolygon(canvas, paint, ol);
      label.draw(canvas, paint);
    }
    if (need) {
      canvas.restore();
    }
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void updateStyle(Context context, FunnelSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status);
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    var s = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
    label.style = s;
  }

  @override
  String toString() {
    String s = '';
    for (var element in attr.points) {
      s = '$s$element ';
    }
    return s;
  }
}
