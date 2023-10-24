import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class Legend extends ChartNotifier2 {
  List<LegendItem>? data;
  bool show;
  bool scroll;
  Position labelPosition;
  Align2 vAlign;
  Align2 hAlign;
  Offset offset;
  Direction direction;
  num itemGap;
  bool allowSelectMulti;
  AreaStyle inactiveStyle;
  LineStyle inactiveBorderStyle;
  AnimatorOption? animator;
  BoxDecoration? decoration;
  EdgeInsets padding;
  TriggerOn triggerOn;

  Legend({
    this.show = true,
    this.scroll = false,
    this.data,
    this.labelPosition = Position.right,
    this.vAlign = Align2.start,
    this.hAlign = Align2.center,
    this.offset = Offset.zero,
    this.direction = Direction.horizontal,
    this.itemGap = 10,
    this.allowSelectMulti = true,
    this.inactiveStyle = const AreaStyle(color: Color(0xFFCCCCCC)),
    this.inactiveBorderStyle = LineStyle.empty,
    this.animator,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.triggerOn = TriggerOn.click,
  });
  Legend.empty({
    this.show = false,
    this.scroll = false,
    this.data,
    this.labelPosition = Position.right,
    this.vAlign = Align2.start,
    this.hAlign = Align2.center,
    this.offset = Offset.zero,
    this.direction = Direction.horizontal,
    this.itemGap = 10,
    this.allowSelectMulti = true,
    this.inactiveStyle =  AreaStyle.empty,
    this.inactiveBorderStyle = LineStyle.empty,
    this.animator,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.triggerOn = TriggerOn.click,
  });





  void inverseSelect() {
    value = Command.inverseSelectLegend;
  }

  void selectAll() {
    value =Command.selectAllLegend;
  }

  void unselect() {
    value = Command.unselectLegend;
  }
}

