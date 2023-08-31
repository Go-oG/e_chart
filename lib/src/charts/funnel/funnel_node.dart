import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class FunnelNode extends DataNode<List<Offset>, ItemData> {
  final int index;
  final ItemData? preData;

  FunnelNode(
    this.index,
    this.preData,
    ItemData data,
    int dataIndex,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(data, dataIndex, 0, [], itemStyle, borderStyle, labelStyle);

  void updatePoint(Context context, FunnelSeries series, List<Offset> pl) {
    attr = pl;
    _path = null;
    updateStyle(context, series);
  }

  Path? _path;

  Path get path {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    each(attr, (p0, p1) {
      if (p1 == 0) {
        path.moveTo(p0.dx, p0.dy);
      } else {
        path.lineTo(p0.dx, p0.dy);
      }
    });
    _path = path;
    return path;
  }

  @override
  String toString() {
    String s = '';
    for (var element in attr) {
      s = '$s$element ';
    }
    return s;
  }

  TextDrawInfo? computeTextPosition(FunnelSeries series) {
    var style = labelStyle;
    if (!style.show) {
      return null;
    }
    Offset p0 = attr[0];
    Offset p1 = attr[1];
    Offset p2 = attr[2];
    Offset p3 = attr[3];
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
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
    return TextDrawInfo(offset, align: textAlign);
  }

  List<Offset>? computeLabelLineOffset(Context context, FunnelSeries series, Offset? textOffset) {
    ChartAlign align = series.getLabelAlign(data, status);
    if (align.inside || textOffset == null) {
      return null;
    }

    LabelStyle style = labelStyle;
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
  void onDraw(Canvas canvas, Paint paint) {
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
    TextDrawInfo? config = labelConfig;
    DynamicText? label = data.label;
    if (label == null || label.isEmpty || config == null) {
      return;
    }
    var style = labelStyle;
    if (!style.show) {
      return;
    }
    List<Offset>? ol = labelLine;
    if (ol != null) {
      style.guideLine?.style.drawPolygon(canvas, paint, ol);
    }
    style.draw(canvas, paint, label, config);
  }

  @override
  bool contains(Offset offset) {
    return path.contains(offset);
  }

  @override
  void updateStyle(Context context, FunnelSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status);
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
    labelConfig = computeTextPosition(series);
  }
}
