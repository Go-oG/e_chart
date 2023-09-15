import 'package:e_chart/e_chart.dart';

class BarGridHelper extends GridHelper<StackItemData, BarGroupData, BarSeries> {
  BarGridHelper(super.context,super.view, super.series);

  @override
  SeriesType get seriesType => SeriesType.bar;
}
