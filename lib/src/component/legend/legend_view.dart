import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LegendComponent extends FlexLayout {
  late final Legend legend;

  LegendComponent(Legend? legend) : super(align: Align2.center, direction: legend?.direction ?? Direction.horizontal) {
    this.legend = legend ?? Legend(show: false);
  }

  @override
  void onCreate() {
    super.onCreate();
    loadData();
  }

  void loadData() {
    if (!legend.show) {
      return;
    }
    List<LegendItem> dataList = [];
    if (legend.data != null && legend.data!.isNotEmpty) {
      dataList.addAll(legend.data!);
    } else {
      for (var item in context.option.series) {
        dataList.addAll(item.getLegendItem(context));
      }
    }
    for (var item in dataList) {
      var style = item.textStyle;
      if (style == null || !style.show) {
        item.textStyle = context.option.theme.subTitle.getStyle();
      }
      addView(LegendItemView(legend, item));
    }
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    if (!legend.show || childCount <= 0) {
      return Size.zero;
    }
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    if (!legend.show || childCount <= 0) {
      return;
    }
    super.onLayout(left, top, right, bottom);
  }

  void onChildClick(LegendItemView child) {
    if (!legend.show) {
      return;
    }

    if (child.isSelected) {
      child.removeState(ViewState.selected);
      context.dispatchEvent(LegendUnSelectedEvent(child.item));
    } else {
      child.addState(ViewState.selected);
      context.dispatchEvent(LegendSelectedEvent(child.item));
    }

    if (!legend.allowSelectMulti) {
      for (var c in children) {
        c.markDirtyWithChild();
        var lc = c as LegendItemView;
        if (lc == child || !lc.isSelected) {
          continue;
        }
        lc.removeState(ViewState.selected);
        context.dispatchEvent(LegendUnSelectedEvent(lc.item));
      }
    }

    invalidate();
  }

  void onChildHover(LegendItemView child, bool select) {
    if (!legend.show) {
      return;
    }
    if (child.isSelected && select) {
      return;
    }
    if (!child.isSelected && !select) {
      return;
    }

    if (select) {
      child.addState(ViewState.selected);
      context.dispatchEvent(LegendSelectedEvent(child.item));
    } else {
      child.removeState(ViewState.selected);
      context.dispatchEvent(LegendUnSelectedEvent(child.item));
    }

    if (!legend.allowSelectMulti) {
      for (var c in children) {
        c.markDirtyWithChild();
        var lc = c as LegendItemView;
        if (lc == child) {
          continue;
        }
        if (select) {
          lc.removeState(ViewState.selected);
          context.dispatchEvent(LegendUnSelectedEvent(lc.item));
        }
      }
    }

    invalidate();
  }
}

class LegendItemView extends GestureView with ViewStateProvider {
  final Legend legend;
  final LegendItem item;
  LabelStyle labelStyle = LabelStyle.empty;

  LegendItemView(this.legend, this.item) {
    labelStyle = item.textStyle ?? LabelStyle.empty;
  }

  Offset symbolOffset = Offset.zero;
  TextDraw? label;

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    num w = item.symbol.size.width;
    num h = item.symbol.size.height;
    Size textSize = labelStyle.measure(item.name, maxLine: 1);
    var p = legend.labelPosition;
    if (p == Position.left || p == Position.right) {
      w += textSize.width + item.gap;
      h = max([h, textSize.height]);
    } else if (p == Position.top || p == Position.bottom) {
      h += textSize.height + item.gap;
      w = max([w, textSize.width]);
    } else {
      w = max([w, textSize.width]);
      h = max([h, textSize.height]);
    }
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    label = null;
    var p = legend.labelPosition;
    var symbolSize = item.symbol.size;
    if (p == Position.left) {
      Offset o = Offset(0, height / 2);
      label = TextDraw(item.name, labelStyle, o, align: Alignment.centerLeft);
      var s = label!.getSize();
      symbolOffset = Offset(s.width + item.gap + symbolSize.width / 2, height / 2);
      return;
    }
    if (p == Position.right) {
      symbolOffset = Offset(symbolSize.width / 2, height / 2);
      Offset o = Offset(symbolSize.width + item.gap, height / 2);
      label = TextDraw(item.name, labelStyle, o, align: Alignment.centerLeft);
      return;
    }
    if (p == Position.top) {
      Offset o = Offset(width / 2, 0);
      label = TextDraw(item.name, labelStyle, o, align: Alignment.topCenter);
      Size s = label!.getSize();
      symbolOffset = Offset(width / 2, s.height + item.gap + symbolSize.height / 2);
      return;
    }

    if (p == Position.bottom) {
      symbolOffset = Offset(width / 2, height - symbolSize.height / 2);
      Offset o = Offset(width / 2, height - symbolSize.height);
      label = TextDraw(item.name, labelStyle, o, align: Alignment.bottomCenter);
      return;
    }
    symbolOffset = Offset(width / 2, height / 2);
    label = TextDraw(item.name, labelStyle, symbolOffset, align: Alignment.center);
  }

  @override
  void onDraw(CCanvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    item.symbol.draw(canvas, mPaint, symbolOffset);
    label?.draw(canvas, mPaint);
    canvas.restore();
  }

  @override
  void onClick(Offset offset) {
    var to = legend.triggerOn;
    if (to == TriggerOn.none) {
      to = TriggerOn.click;
    }
    if (to == TriggerOn.mouseMove) {
      return;
    }
    var parent = this.parent;
    if (parent is LegendComponent) {
      parent.onChildClick(this);
    }
  }

  @override
  void onHoverStart(Offset offset) {
    var to = legend.triggerOn;
    if (to == TriggerOn.none) {
      to = TriggerOn.click;
    }
    if (to == TriggerOn.click) {
      return;
    }
    var parent = this.parent;
    if (parent is LegendComponent) {
      parent.onChildHover(this, true);
    }
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    var to = legend.triggerOn;
    if (to == TriggerOn.none) {
      to = TriggerOn.click;
    }
    if (to == TriggerOn.click) {
      return;
    }
    var parent = this.parent;
    if (parent is LegendComponent) {
      parent.onChildHover(this, true);
    }
  }

  @override
  void onHoverEnd() {
    var to = legend.triggerOn;
    if (to == TriggerOn.none) {
      to = TriggerOn.click;
    }
    if (to == TriggerOn.click) {
      return;
    }
    var parent = this.parent;
    if (parent is LegendComponent) {
      parent.onChildHover(this, false);
    }
  }

  @override
  bool get enableClick => true;

  @override
  bool get enableDoubleClick => false;

  @override
  bool get enableDrag => false;

  @override
  bool get enableLongPress => false;

  @override
  bool get enableScale => false;
}
