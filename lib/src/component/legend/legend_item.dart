import 'package:e_chart/e_chart.dart';

class LegendItem {
  late final String seriesId;
  DynamicText name;
  ChartSymbol symbol;
  num gap;
  LabelStyle? textStyle;

  LegendItem(
    this.name,
    this.symbol, {
    String? seriesId,
    this.gap = 8,
    this.textStyle,
  }) {
    if (seriesId == null || seriesId.isEmpty) {
      this.seriesId = randomId();
    } else {
      this.seriesId = seriesId;
    }
  }
}
