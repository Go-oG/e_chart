import 'package:e_chart/src/style/index.dart';

import '../../model/dynamic_text.dart';

class ContextMenu {
  final DynamicText? title;
  final LabelStyle? titleStyle;
  final List<MenuItem> itemList;

  ContextMenu(
    this.itemList, {
    this.title,
    this.titleStyle,
  });
}

class MenuItem {
  final DynamicText text;
  final LabelStyle textStyle;
  final DynamicText? subText;
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
