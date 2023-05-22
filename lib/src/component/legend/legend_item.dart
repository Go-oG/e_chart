
import '../../model/enums/position.dart';
import '../../style/label.dart';
import '../../style/symbol/empty_symbol.dart';
import '../../style/symbol/symbol.dart';

class LegendItem {
  final String id;
  final String name;
  final Position position;///文字位置
  final num gap;
  LabelStyle textStyle = const LabelStyle();
  ChartSymbol symbol = const EmptySymbol();

  LegendItem(
    this.name, {
    this.id = '',
    this.position = Position.right,
    this.gap = 8,
  });
}
