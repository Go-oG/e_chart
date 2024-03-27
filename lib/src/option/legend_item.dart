import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../component/legend/legend_item_view.dart';

class LegendItem extends Disposable {
  final String id = randomId();
  late final String seriesId;
  late DynamicText name;
  late ChartSymbol symbol;
  num gap;
  LabelStyle? textStyle;
  bool selected = true;

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

  LegendItem.empty({
    String? seriesId,
    this.gap = 8,
    this.textStyle,
  }) {
    name = DynamicText.empty;
    symbol = EmptySymbol.empty;
    if (seriesId == null || seriesId.isEmpty) {
      this.seriesId = randomId();
    } else {
      this.seriesId = seriesId;
    }
  }

  Widget toWidget(Direction direction, Legend legend, Fun2<LegendItem, bool>? call) {
    return LegendItemView(
      item: this,
      legend: legend,
      call: call,
    );
  }

  @override
  void dispose() {
    name = DynamicText.empty;
    symbol = EmptySymbol.empty;
    textStyle = null;
    super.dispose();
  }
}
