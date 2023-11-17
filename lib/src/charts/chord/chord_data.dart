import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ChordData extends RenderData<Arc> {
  ChordData({super.id, super.name}) {
    attr = Arc.zero;
  }

  num value = 0;

  @override
  bool contains(Offset offset) {
    if (attr.contains(offset)) {
      return true;
    }
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (attr.isEmpty) {
      return;
    }
    itemStyle.drawArc(canvas, paint, attr);
    borderStyle.drawPath(canvas, paint, attr.toPath(),
        drawDash: true,
        bound: Rect.fromCircle(
          center: attr.center,
          radius: attr.outRadius.toDouble(),
        ));
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant ChordSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.updatePainter(style: series.getLabelStyle(context, this));
  }
}

class ChordLink extends RenderData<Path> {
  static final _emptyPath = Path();
  ChordData source;
  ChordData target;
  num value;

  ///布局中使用的数据
  num sourceStartAngle = 0;
  num sourceEndAngle = 0;

  num targetStartAngle = 0;
  num targetEndAngle = 0;

  ChordLink(this.source, this.target, this.value, {super.id, super.name}) {
    attr = _emptyPath;
    if (value < 0) {
      throw ChartError("value must >0");
    }
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawPath(canvas, paint, attr);
    borderStyle.drawPath(canvas, paint, attr);
  }

  @override
  void updateStyle(Context context, covariant ChordSeries series) {
    itemStyle = series.getLinkItemStyle(context, this);
    borderStyle = series.getLinkBorderStyle(context, this);
  }
}
