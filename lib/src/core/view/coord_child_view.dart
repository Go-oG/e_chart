import '../layout/layout_helper.dart';
import '../series/series.dart';
import 'series_view.dart';

abstract class CoordChildView<T extends ChartSeries, L extends LayoutHelper> extends SeriesView<T, L> {
  CoordChildView(super.context, super.series);

  @override
  bool get enableDrag => false;

  @override
  bool get enableScale => false;
}
