import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:flutter/material.dart';

import '../group/scroll_view.dart';
import 'tool_tip_item_view.dart';

///单个坐标系只有一个ToolTip
class ToolTipView extends LinearLayout {
  ToolTip toolTip;
  ToolTipMenu? menu;

  ToolTipView(this.toolTip) : super(direction: Direction.vertical) {
    layoutParams = const LayoutParams.wrapAll();
    zLevel = 10000;
  }

  TitleView? titleView;

  @override
  void onDispose() {
    menu = null;
    toolTip = ToolTip(show: false);
    titleView = null;
    super.onDispose();
  }

  void updateView(ToolTipMenu? menu) {
    this.menu = menu;
    children.clear();
    if (menu == null) {
      this.layout(0, top, right, bottom);
      return;
    }
    if (menu.title != null) {
      titleView = TitleView(menu.title!, menu.titleStyle ?? const LabelStyle());
      addView(titleView!);
    }

    var sv = ScrollLayout();
    sv.layoutParams = const LayoutParams.matchAll();

    var ll = LinearLayout();
    ll.layoutParams = const LayoutParams.wrapAll();

    for (var item in menu.itemList) {
      var itemView = ToolTipItemView(item);
      itemView.layoutParams = const LayoutParams.wrapAll(
        leftPadding: SNumber.number(8),
        topPadding: SNumber.number(8),
        rightPadding: SNumber.number(8),
        bottomPadding: SNumber.number(8),
      );
      ll.addView(itemView);
    }
    sv.addView(ll);
    children.add(sv);
  }

  void updatePosition(Offset offset) {
    this.layout(left + offset.dx, top + offset.dy, right + offset.dx, bottom + offset.dy);
  }

  @override
  bool get clipSelf => true;

  @override
  void onDrawBackground(CCanvas canvas) {
    if (!toolTip.show) {
      return;
    }
    var tr = selfBoxBound;
    Rect rect = Rect.fromLTRB(tr.left + 4, tr.top + 4, tr.right - 4, tr.bottom - 4);
    toolTip.backgroundStyle.drawRect(canvas, mPaint, rect, toolTip.corner);
    toolTip.borderStyle?.drawRect(canvas, mPaint, rect, toolTip.corner);
  }
}
