import '../../../e_chart.dart';

abstract class CoordChildView<T extends ChartSeries, L extends LayoutHelper> extends SeriesView<T, L> {
  CoordChildView(super.context, super.series);

  @override
  bool get enableDrag => false;

  @override
  bool get enableScale => false;
}
