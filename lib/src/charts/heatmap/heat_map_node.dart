import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HeatMapNode extends DataNode<Rect, HeatMapData> {
  HeatMapNode(
    HeatMapData data,
    int dataIndex,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(data, dataIndex, -1, Rect.zero, itemStyle, borderStyle, labelStyle);

  Alignment labelAlign = Alignment.center;

  @override
  void onDraw(Canvas canvas, Paint paint) {
    itemStyle.drawRect(canvas, paint, attr);
    borderStyle.drawRect(canvas, paint, attr);
    var label = data.label;
    if (label == null || label.isEmpty) {
      return;
    }
    labelStyle.draw(canvas, paint, label, TextDrawInfo.fromRect(attr, labelAlign));
  }

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void updateStyle(Context context,covariant HeatMapSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, status) ?? LabelStyle.empty;
  }
}
