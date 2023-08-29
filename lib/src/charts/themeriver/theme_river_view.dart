import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'theme_river_helper.dart';

class ThemeRiverView extends SeriesView<ThemeRiverSeries, ThemeRiverHelper> {

  ThemeRiverView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var nodeList=layoutHelper.nodeList;
    canvas.save();
    var tx=layoutHelper.tx;
    var ty=layoutHelper.ty;
    var ap=layoutHelper.animatorPercent;
    canvas.translate(tx, ty);
    if (series.direction == Direction.horizontal) {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width * ap, height));
    } else {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width, height * ap));
    }
    for (var ele in nodeList) {
      AreaStyle style = ele.areaStyle ?? layoutHelper.getStyle(ele);
      style.drawPath(canvas, mPaint, ele.drawPath);
    }

    //这里拆分开是为了避免文字被遮挡
    for (var element in nodeList) {
      drawText(canvas, element);
    }
    canvas.restore();
  }

  void drawText(Canvas canvas, ThemeRiverNode node) {
    var label = node.data.label;
    var config=node.attr.textConfig;
    if (config==null||label == null || label.isEmpty) {
      return;
    }
    LabelStyle? style = node.labelStyle ?? layoutHelper.getLabelStyle(node);
    if (style == null) {
      return;
    }
    style.draw(canvas, mPaint, label, config);
  }

  @override
  ThemeRiverHelper buildLayoutHelper() {
    return ThemeRiverHelper(context, series);
  }
}
