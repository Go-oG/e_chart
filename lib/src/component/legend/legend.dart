import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/enums/align.dart';
import '../../model/enums/direction.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'legend_item.dart';

class Legend {
  bool show = true;
  bool scroll = false;
  List<LegendItem> itemList;
  num itemGap = 10;
  Size symbolSize = const Size(25, 14);
  Direction direction = Direction.horizontal;
  BoxDecoration decoration = const BoxDecoration();
  ChartAlign position = ChartAlign.bottomCenter;
  EdgeInsetsGeometry padding = EdgeInsets.zero;

  StyleFun<LegendItem, AreaStyle> itemStyleFun;
  StyleFun<LegendItem, LabelStyle> labelStyleFun;
  Legend({
    required this.itemList,
    required this.itemStyleFun,
    required this.labelStyleFun,
  });




}
