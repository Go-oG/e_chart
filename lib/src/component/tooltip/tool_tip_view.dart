import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';

import '../../core/view_group.dart';
import '../../style/label.dart';
import '../group/linear_layout_group.dart';
import 'context_menu.dart';
import 'context_menu_builder.dart';
import 'tool_tip_item_view.dart';

///整个图表只有一个ToolTip
class ToolTipView extends LinearLayout {
  final ToolTipBuilder builder;

  ToolTipView(this.builder) {
    ContextMenu? menu = builder.onCreatedContextMenu();
    if (menu != null) {
      if (menu.title != null && menu.title!.isNotEmpty) {
        MenuItem item =
            MenuItem(menu.title!, menu.titleStyle ?? const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 17)));
        addView(ToolTipItemView(item));
      }
      for (var item in menu.itemList) {
        addView(ToolTipItemView(item));
      }
    }
  }
}
