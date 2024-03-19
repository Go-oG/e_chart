import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:flutter/material.dart';

import '../group/scroll_view.dart';
import 'tool_tip_item_view.dart';

///单个坐标系只有一个ToolTip
class ToolTipView extends LinearLayout {
  ToolTip toolTip;
  ToolTipMenu? menu;

  ToolTipView(Context context, this.toolTip) : super(context, direction: Direction.vertical) {
    layoutParams = LayoutParams.wrapAll();
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
      titleView = TitleView(context, menu.title!, menu.titleStyle ?? const LabelStyle());
      addView(titleView!);
    }

    var sv = ScrollLayout(context);
    sv.layoutParams = LayoutParams.matchAll();

    var ll = LinearLayout(context);
    ll.layoutParams = LayoutParams.wrapAll();

    for (var item in menu.itemList) {
      var itemView = ToolTipItemView(context, item);
      itemView.layoutParams = LayoutParams.wrapAll(
        leftPadding: 8,
        topPadding: 8,
        rightPadding: 8,
        bottomPadding: 8,
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
  void onDrawBackground(CCanvas canvas) {
    if (!toolTip.show) {
      return;
    }
    var tr = boxBound.translate(-left, -top);
    Rect rect = Rect.fromLTRB(tr.left + 4, tr.top + 4, tr.right - 4, tr.bottom - 4);
    toolTip.backgroundStyle.drawRect(canvas, mPaint, rect, toolTip.corner);
    toolTip.borderStyle?.drawRect(canvas, mPaint, rect, toolTip.corner);
  }
}
