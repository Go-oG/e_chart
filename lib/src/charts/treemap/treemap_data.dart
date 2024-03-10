import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class TreeMapData extends ChartTree<Rect, TreeMapData> {
  TreeMapData(super.parent, super.children, num value, {super.id, super.name}) : super(value: value) {
    setExpand(false, false);
  }

  ///计算面积比
  double get areaRatio {
    if (parent == null) {
      return 1;
    }
    return value / parent!.value;
  }

  @override
  set attr(Rect a) {
    super.attr = a;
    var center = a.center;
    x = center.dx;
    y = center.dy;
    size = a.size;
  }

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Rect rect = attr;
    itemStyle.drawRect(canvas, paint, rect);
    borderStyle.drawRect(canvas, paint, rect);
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant TreeMapSeries series) {
    itemStyle = series.getAreaStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    double w = attr.width <= 0 ? double.infinity : attr.width - series.labelPadding.dx;
    if (w <= 0) {
      w = attr.width;
    }
    double h = attr.height <= 0 ? double.infinity : attr.height - series.labelPadding.dy;
    if (h <= 0) {
      h = attr.height;
    }
    label.updatePainter(style: series.getLabelStyle(context, this), maxWidth: w, maxHeight: h);
  }

  @override
  void updateLabelPosition(Context context, covariant TreeMapSeries series) {
    Rect rect = attr;
    var align = series.labelAlignFun?.call(this) ?? Alignment.topLeft;
    double x = rect.center.dx + align.x * rect.width / 2;
    double y = rect.center.dy + align.y * rect.height / 2;
    double w = attr.width <= 0 ? double.infinity : attr.width - series.labelPadding.dx;
    if (w <= 0) {
      w = attr.width;
    }
    double h = attr.height <= 0 ? double.infinity : attr.height - series.labelPadding.dy;
    if (h <= 0) {
      h = attr.height;
    }
    if (align.x <= 0) {
      x += series.labelPadding.dx;
    } else {
      x -= series.labelPadding.dx;
    }
    if (align.y <= 0) {
      y += series.labelPadding.dy;
    } else {
      y -= series.labelPadding.dy;
    }
    label.updatePainter(offset: Offset(x, y), align: toInnerAlign(align), maxWidth: w, maxHeight: h);
  }

  @override
  Rect initAttr()=>Rect.zero;
}
