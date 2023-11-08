import 'package:e_chart/e_chart.dart';

import 'hex_bin_helper.dart';

class HexbinView extends SeriesView<HexbinSeries, HexBinHelper> {
  HexbinView(super.series);

  @override
  bool get enableDrag => true;

  @override
  void onDraw(CCanvas canvas) {
    var tr = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(tr.dx, tr.dy);
    each(layoutHelper.showNodeList, (node, p1) {
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  HexBinHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return HexBinHelper(context, this, series);
  }

}
