import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class SunburstData extends ChartTree<Arc, SunburstData> {
  SunburstData(
    super.parent,
    super.children,
    num value, {
    super.id,
    super.name,
  }) {
    this.value = value;
  }

  double alpha = 1;

  @override
  void updateLabelPosition(Context context, SunburstSeries series) {
    label.updatePainter();
    if (label.notDraw) {
      return;
    }
    var arc = attr;
    label.updatePainter();
    Size size = label.getSize();
    double labelMargin = series.labelMarginFun?.call(this) ?? 0;
    if (labelMargin > 0) {
      size = Size(size.width + labelMargin, size.height);
    }

    var originAngle = arc.startAngle + arc.sweepAngle / 2;

    var dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    var dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    var align = series.labelAlignFun?.call(this) ?? Align2.start;
    if (align == Align2.start) {
      dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + size.width / 2);
      dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + size.width / 2);
    } else if (align == Align2.end) {
      dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.outRadius - size.width / 2);
      dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.outRadius - size.width / 2);
    }
    var textPosition = Offset(dx, dy).translate2(attr.center);
    double rotateMode = series.rotateFun?.call(this) ?? -1;
    double rotateAngle = 0;

    if (rotateMode <= -2) {
      ///切向
      if (originAngle >= 360) {
        originAngle = originAngle % 360;
      }
      if (originAngle >= 0 && originAngle < 90) {
        rotateAngle = originAngle % 90;
      } else if (originAngle >= 90 && originAngle < 270) {
        rotateAngle = originAngle - 180;
      } else {
        rotateAngle = originAngle - 360;
      }
    } else if (rotateMode <= -1) {
      ///径向
      if (originAngle >= 360) {
        originAngle = originAngle % 360;
      }
      if (originAngle >= 0 && originAngle < 180) {
        rotateAngle = originAngle - 90;
      } else {
        rotateAngle = originAngle - 270;
      }
    } else if (rotateMode > 0) {
      rotateAngle = rotateMode;
    }

    label.updatePainter(
      rotate: rotateAngle,
      offset: textPosition,
      align: Alignment.center,
    );
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawArc(canvas, paint, attr);
    borderStyle.drawPath(canvas, paint, attr.toPath());
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant SunburstSeries series) {
    itemStyle = series.getAreaStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.updatePainter(style: series.getLabelStyle(context, this));
  }

  @override
  String toString() {
    var s = super.toString();
    return "$s\nAttr:\n${attr}";
  }

  @override
  Arc initAttr() => Arc.zero;
}

class SunburstVirtualNode extends SunburstData {
  SunburstVirtualNode(SunburstData child, Arc attr) : super(null, [child], 0) {
    child.parent = null;
    add(child);
    value = child.value;
    this.attr = attr;
  }

  final AreaStyle bs = const AreaStyle(color: Colors.black);

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    bs.drawArc(canvas, paint, attr);
  }
}
