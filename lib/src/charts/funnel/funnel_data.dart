import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class FunnelData extends RenderData<List<Offset>> {
  num value;

  FunnelData? preData;
  double scale = 1;

  Offset center = Offset.zero;

  Path _path=Path();

  FunnelData(this.value, {super.id, super.name});



  @override
  set attr(List<Offset> a) {
    super.attr=a;
    _path.reset();
    each(a, (p0, p1) {
      if(p1==0){
        _path.moveTo2(p0);
      }else{
        _path.lineTo2(p0);
      }
    });

    if (a.length < 4) {
      center = Offset.zero;
      return;
    }
    Offset p0 = attr[0];
    Offset p1 = attr[1];
    Offset p3 = attr[3];
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
    center = Offset(centerX, centerY);
  }

  @override
  void updateLabelPosition(Context context, FunnelSeries series) {
    var style = label.style;
    Offset p0 = attr[0];
    Offset p1 = attr[1];
    Offset p2 = attr[2];
    double centerX = center.dx;
    double centerY = center.dy;
    double topW = (p1.dx - p0.dx).abs();
    ChartAlign align = series.getLabelAlign(this);
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
    label.updatePainter(text: label.text, offset: offset, align: textAlign);
    labelLine = computeLabelLineOffset(context, series, label.offset) ?? [];
  }

  List<Offset>? computeLabelLineOffset(Context context, FunnelSeries series, Offset? textOffset) {
    ChartAlign align = series.getLabelAlign(this);
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
    itemStyle.drawPolygonArea(canvas, paint, attr);
    borderStyle.drawPolygon(canvas, paint, attr);
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
    return _path.contains(offset);
  }

  @override
  void updateStyle(Context context, FunnelSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    var s = series.getLabelStyle(context, this);
    label.style = s;
  }

  @override
  String toString() {
    String s = '';
    for (var element in attr) {
      s = '$s$element ';
    }
    return s;
  }

  @override
  List<Offset> initAttr() =>[];
}
