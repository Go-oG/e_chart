import 'package:e_chart/e_chart.dart';

class LegendItem {
  late final String id;
  DynamicText name;
  Position position;

  ///文字位置
  num gap;
  LabelStyle textStyle = const LabelStyle();
  ChartSymbol symbol = EmptySymbol();

  LegendItem(
    this.name, {
    String? id,
    this.position = Position.right,
    this.gap = 8,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }
}
