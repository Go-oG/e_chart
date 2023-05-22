import 'package:e_chart/src/style/index.dart';

class ContextMenu {
  final String? title;
  final LabelStyle? titleStyle;
  final List<MenuItem> itemList;

  ContextMenu(
    this.itemList, {
    this.title,
    this.titleStyle,
  });
}

class MenuItem {
  final String text;
  final LabelStyle textStyle;
  final String? subText;
  final LabelStyle? subTextStyle;
  final ChartSymbol? symbol;

  MenuItem(
    this.text,
    this.textStyle, {
    this.subText,
    this.subTextStyle,
    this.symbol,
  });
}
