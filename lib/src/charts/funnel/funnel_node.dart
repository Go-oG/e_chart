import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class FunnelNode extends DataNode<List<Offset>,ItemData> {
  final int index;
  final ItemData? preData;

  ///标识顶点坐标
  ///leftTop:[0];rightTop:[1];rightBottom:[2]; leftBottom:[3];
  List<Offset> pointList = [];

  FunnelNode(this.index, this.preData, ItemData data):super(data,[]);

  TextDrawConfig? textConfig;
  List<Offset>? labelLine;

  LabelStyle? labelStyle;
  AreaStyle areaStyle = const AreaStyle();

  void update(Context context, FunnelSeries series) {
    ChartTheme chartTheme = context.config.theme;
    FunnelTheme theme = chartTheme.funnelTheme;
    AreaStyle? areaStyle = FunnelLayout.getAreaStyle(context, series, this);
    this.areaStyle = areaStyle;

    LabelStyle? labelStyle = series.labelStyleFun?.call(this);
    if (labelStyle == null && series.labelStyleFun != null) {
      labelStyle = theme.labelStyle;
    }
    this.labelStyle = labelStyle;

    textConfig = computeTextPosition(series);
    labelLine = computeLabelLineOffset(series, textConfig?.offset);
  }

  void updatePoint(Context context, FunnelSeries series, List<Offset> pl) {
    pointList=pl;
    _path = null;
    update(context, series);
  }


  Path? _path;

  Path get path {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    each(pointList, (p0, p1) {
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
    for (var element in pointList) {
      s = '$s$element ';
    }
    return s;
  }

  TextDrawConfig? computeTextPosition(FunnelSeries series) {
    LabelStyle? style = labelStyle;
    if (style == null || !style.show) {
      return null;
    }
    Offset p0 = pointList[0];
    Offset p1 = pointList[1];
    Offset p2 = pointList[2];
    Offset p3 = pointList[3];
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
    double topW = (p1.dx - p0.dx).abs();
    FunnelAlign align = series.labelAlign;
    double x = centerX + align.align.x * topW / 2;
    double y = centerY + align.align.y * (p1.dy - p2.dy).abs() / 2;
    if (!series.labelAlign.inside) {
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
    if (!series.labelAlign.inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    return TextDrawConfig(offset, align: textAlign);
  }

  List<Offset>? computeLabelLineOffset(FunnelSeries series, Offset? textOffset) {
    if (series.labelAlign.inside || textOffset == null) {
      return null;
    }

    LabelStyle? style = series.labelStyleFun?.call(this);
    if (style == null || !style.show) {
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
      int dir = series.labelAlign.align.x > 0 ? -1 : 1;
      x2 = textOffset.dx + dir * gap[0];
      x1 = x2 + dir * lineWidth;
      y1 = y2 = textOffset.dy;
    } else {
      x1 = x2 = textOffset.dx;
      int dir = series.labelAlign.align.y > 0 ? -1 : 1;
      y2 = textOffset.dy + dir * gap[1];
      y1 = y2 + dir * lineWidth;
    }
    return [Offset(x1, y1), Offset(x2, y2)];
  }


  @override
  void setP(List<Offset> po) {
    pointList=po;
  }

  @override
  List<Offset> getP() {
    return List.from(pointList);
  }

}
