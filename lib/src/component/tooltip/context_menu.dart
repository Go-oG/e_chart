import 'package:e_chart/src/style/index.dart';

import '../../model/dynamic_text.dart';

class ContextMenu {
   DynamicText? title;
   LabelStyle? titleStyle;
   List<MenuItem> itemList;

  ContextMenu(
    this.itemList, {
    this.title,
    this.titleStyle,
  });
}

class MenuItem {
   DynamicText text;
   LabelStyle textStyle;
   DynamicText? subText;
   LabelStyle? subTextStyle;
   ChartSymbol? symbol;

  MenuItem(
    this.text,
    this.textStyle, {
    this.subText,
    this.subTextStyle,
    this.symbol,
  });
}
