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
  DynamicText title;
  LabelStyle titleStyle;
  DynamicText? desc;
  LabelStyle? descStyle;

  ChartSymbol? symbol;

  MenuItem(
    this.title,
    this.titleStyle, {
    this.symbol,
    this.descStyle,
    this.desc,
  });
}
