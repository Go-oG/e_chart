import 'package:e_chart/e_chart.dart';

class BarGridHelper extends StackGridHelper<StackItemData, BarGroupData, BarSeries> {
  BarGridHelper(super.context, super.series);

  @override
  SeriesType get seriesType => SeriesType.bar;
}
