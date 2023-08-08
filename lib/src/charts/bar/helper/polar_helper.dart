import 'package:e_chart/e_chart.dart';

class BarPolarHelper extends PolarHelper<StackItemData, BarGroupData, BarSeries> {
  BarPolarHelper(super.context, super.series);

  @override
  SeriesType get seriesType => SeriesType.bar;
}
