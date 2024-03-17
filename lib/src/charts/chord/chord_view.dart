import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/chord/chord_helper.dart';

class ChordView extends SeriesView<ChordSeries, ChordHelper> {
  ChordView(super.context,super.series);

  @override
  ChordHelper buildLayoutHelper(ChordHelper? oldHelper) {
    if (oldHelper != null) {
      oldHelper.view = this;
      oldHelper.context = context;
      oldHelper.series = series;
      return oldHelper;
    }
    return ChordHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    canvas.save();
    canvas.translate(translationX, translationY);
    each(layoutHelper.linkSet, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
    each(layoutHelper.dataSet, (data, p1) {
      data.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  bool get enableDrag => true;
}
