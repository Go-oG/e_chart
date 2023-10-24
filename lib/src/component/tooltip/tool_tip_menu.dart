import '../../model/data.dart';
import '../style/index.dart';
import '../symbol/chart_symbol.dart';

class ToolTipMenu {
  DynamicText? title;
  LabelStyle? titleStyle;
  List<MenuItem> itemList;

  ToolTipMenu(
    this.itemList, {
    this.title,
    this.titleStyle,
  });
}

class MenuItem {
  static final MenuItem empty=MenuItem(DynamicText.empty, LabelStyle.empty);


  final DynamicText title;
  final LabelStyle titleStyle;
  final DynamicText? desc;
  final LabelStyle? descStyle;
  final ChartSymbol? symbol;

  MenuItem(
    this.title,
    this.titleStyle, {
    this.symbol,
    this.descStyle,
    this.desc,
  });
}
