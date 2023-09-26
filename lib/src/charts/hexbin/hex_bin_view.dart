import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'hex_bin_helper.dart';

class HexbinView extends SeriesView<HexbinSeries, HexbinHelper> {
  HexbinView(super.series);

  @override
  bool get enableDrag => true;

  var sw = Stopwatch();

  @override
  void onDraw(CCanvas canvas) {
    sw.reset();
    var tr = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(tr.dx, tr.dy);
    each(layoutHelper.showNodeList, (node, p1) {
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  HexbinHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return HexbinHelper(context, this, series);
  }
}
