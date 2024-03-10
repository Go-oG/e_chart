import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/layout/layout_result.dart';
import 'package:flutter/material.dart';

class PieData extends RenderData<Arc> {
  num value;

  PieData(
    this.value, {
    super.id,
    super.name,
  });

  ///计算文字的位置
  Path? guidLinePath;

  void updateTextPosition(PieSeries series) {
    guidLinePath = null;
    var labelStyle = label.style;
    if (series.labelAlign == CircleAlign.center) {
      label.updatePainter(offset: attr.center, align: Alignment.center);
    } else if (series.labelAlign == CircleAlign.inside) {
      double radius = (attr.innerRadius + attr.outRadius) / 2;
      double angle = attr.startAngle + attr.sweepAngle / 2;
      var offset = circlePoint(radius, angle).translate(attr.center.dx, attr.center.dy);
      label.updatePainter(offset: offset, align: Alignment.center);
    } else if (series.labelAlign == CircleAlign.outside) {
      num expand = labelStyle.guideLine?.length ?? 0;
      double centerAngle = attr.startAngle + attr.sweepAngle / 2;
      Offset offset = circlePoint(attr.outRadius + expand, centerAngle, attr.center);
      Alignment align = toAlignment(centerAngle, false);
      if (centerAngle >= 90 && centerAngle <= 270) {
        align = Alignment.centerRight;
      } else {
        align = Alignment.centerLeft;
      }
      label.updatePainter(offset: offset, align: align);
    } else {
      label.updatePainter(style: LabelStyle.empty);
    }

    if (series.labelAlign == CircleAlign.outside) {
      Offset center = attr.center;
      Offset tmpOffset = circlePoint(attr.outRadius, attr.startAngle + (attr.sweepAngle / 2), center);
      Offset tmpOffset2 = circlePoint(
        attr.outRadius + (labelStyle.guideLine?.length ?? 0),
        attr.startAngle + (attr.sweepAngle / 2),
        center,
      );
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(label.offset.dx, label.offset.dy);
      guidLinePath = path;
    }
  }

  @override
  bool contains(Offset offset) {
    return offset.inArc(attr);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawArc(canvas, paint, attr);
    borderStyle.drawPath(canvas, paint, attr.toPath());

    var ls = label.style;
    if (guidLinePath != null) {
      ls.guideLine?.style.drawPath(canvas, paint, guidLinePath!);
    }
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, PieSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.updatePainter(style: series.getLabelStyle(context, this));
  }

  @override
  Arc initAttr() => Arc.zero;
}
