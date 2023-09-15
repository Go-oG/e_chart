import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'hex_bin_helper.dart';

class HexbinView extends SeriesView<HexbinSeries, HexbinHelper> {
  HexbinView(super.series);

  @override
  bool get enableDrag => true;

  @override
  void onDraw(CCanvas canvas) {
    var tr = layoutHelper.getTranslation();
    var sRect = Rect.fromLTWH(-tr.dx, -tr.dy, width, height);
    canvas.save();
    canvas.translate(tr.dx, tr.dy);
    each(layoutHelper.nodeList, (node, p1) {
      if (sRect.containsCircle(node.attr.center, node.symbol.r)) {
        node.onDraw(canvas, mPaint);
      }
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
