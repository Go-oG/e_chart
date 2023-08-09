import 'dart:ui';
import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:flutter/material.dart';

import '../group/scroll_view.dart';
import 'tool_tip_item_view.dart';

///单个坐标系只有一个ToolTip
class ToolTipView extends LinearLayout {
  final ToolTip toolTip;
  ToolTipMenu? menu;

  ToolTipView(this.toolTip) : super(direction: Direction.vertical) {
    layoutParams = const LayoutParams.wrapAll();
    zLevel=1000;
  }

  TitleView? titleView;

  void updateView(ToolTipMenu? menu) {
    this.menu = menu;
    children.clear();
    if (menu == null) {
      layout(0, top, right, bottom);
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
      itemView.layoutParams = const LayoutParams.wrapAll(padding: EdgeInsets.all(8));
      ll.addView(itemView);
    }
    sv.addView(ll);
    children.add(sv);
  }

  void updatePosition(Offset offset) {
    layout(left + offset.dx, top + offset.dy, right + offset.dx, bottom + offset.dy);
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    var lp = layoutParams;
    var padding = lp.padding;
    double w = 0, h = 0;
    if (lp.width.isNormal) {
      w = lp.width.convert(parentWidth);
    } else {
      w = parentWidth;
    }
    if (lp.height.isNormal) {
      h = lp.height.convert(parentHeight);
    } else {
      h = parentHeight;
    }
    if (toolTip.maxWidth != null) {
      w = m.min(w, toolTip.maxWidth!).toDouble();
    }
    if (toolTip.minWidth != null) {
      if (w < toolTip.minWidth!) {
        w = toolTip.minWidth!.toDouble();
      }
    }
    if (toolTip.maxHeight != null) {
      h = m.min(h, toolTip.maxHeight!).toDouble();
    }
    if (toolTip.minHeight != null) {
      if (h < toolTip.minHeight!) {
        h = toolTip.minHeight!.toDouble();
      }
    }
    w -= padding.horizontal;
    h -= padding.vertical;
    for (var c in children) {
      c.measure(w, h);
    }

    w = 0;
    h = 0;
    for (var c in children) {
      w = max([w, c.width]).toDouble();
      h += c.height;
    }

    w += toolTip.padding.horizontal;
    h += toolTip.padding.vertical;
    Size size = Size(w.toDouble(), h.toDouble());
    return size;
  }

  @override
  bool? get clipSelf => true;

  @override
  void onDrawBackground(Canvas canvas) {
    if (!toolTip.show) {
      return;
    }
    var tr = selfBoxBound;
    Rect rect = Rect.fromLTRB(tr.left + 4, tr.top + 4, tr.right - 4, tr.bottom - 4);
    toolTip.backgroundStyle.drawRect(canvas, mPaint, rect, toolTip.corner);
    toolTip.borderStyle?.drawRect(canvas, mPaint, rect, toolTip.corner);
  }
}
