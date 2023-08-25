import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinView extends SeriesView<HexbinSeries, HexbinLayout> {
  HexbinView(super.series);

  @override
  void onDraw(Canvas canvas) {
    for (var node in layoutHelper.nodeList) {
      Path path = node.attr.shape.toPath(true);
      AreaStyle? style = series.getItemStyle(context, node.data, node.dataIndex, node.status);
      style?.drawPath(canvas, mPaint, path);

      var lineStyle = series.getBorderStyle(context, node.data, node.dataIndex, node.status);
      if(lineStyle!=null){
        num r=node.attr.shape.r;
        double scale=1-(lineStyle.width/(2*r));
        Matrix4 m4 = Matrix4.identity();
        m4.translate(node.attr.center.dx, node.attr.center.dy);
        m4.scale(scale,scale);
        m4.translate(-node.attr.center.dx, -node.attr.center.dy);
        var path2 = path.transform(m4.storage);
        lineStyle.drawPath(canvas, mPaint, path2, drawDash: true, needSplit: false);
      }

      DynamicText? s = node.data.label;
      if (s == null || s.isEmpty) {
        continue;
      }
      LabelStyle? labelStyle = series.getLabelStyle(context, node.data, node.dataIndex, node.status);
      if (labelStyle != null && labelStyle.show) {
        TextDrawInfo config = TextDrawInfo(node.attr.center, textAlign: TextAlign.center);
        labelStyle.draw(canvas, mPaint, s, config);
      }
    }
  }

  @override
  HexbinLayout buildLayoutHelper() {
    series.layout.context = context;
    series.layout.series = series;
    return series.layout;
  }
}
