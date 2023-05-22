import 'package:flutter/material.dart';

import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import 'legend_item.dart';

class Legend {
  bool show = true;
  bool scroll = false;
  List<LegendItem> itemList;
  
  Align2 vAlign = Align2.start;
  Align2 hAlign = Align2.center;
  
  Offset offset = Offset.zero;
  Direction direction = Direction.horizontal;

  num itemGap = 10;
  BoxDecoration decoration = const BoxDecoration();
  EdgeInsetsGeometry padding = EdgeInsets.zero;

  Legend({required this.itemList});
}
