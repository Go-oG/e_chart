import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class Legend extends ChartNotifier2 {
  List<LegendItem>? data;
  bool show;

  ///是否允许滚动 如果允许则将不会使用Wrap,否则会使用Wrap
  bool scroll;
  Align2 mainAlign;
  Align2 crossAlign;

  Offset offset;
  Direction direction;
  Position labelPosition;
  WrapAlignment vAlign;
  WrapAlignment hAlign;
  double hGap;
  double vGap;
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
    this.mainAlign = Align2.start,
    this.crossAlign = Align2.start,
    this.data,
    this.labelPosition = Position.right,
    this.vAlign = WrapAlignment.start,
    this.hAlign = WrapAlignment.start,
    this.offset = Offset.zero,
    this.direction = Direction.horizontal,
    this.hGap = 10,
    this.vGap = 10,
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
    this.mainAlign = Align2.start,
    this.crossAlign = Align2.start,
    this.data,
    this.labelPosition = Position.right,
    this.vAlign = WrapAlignment.start,
    this.hAlign = WrapAlignment.start,
    this.offset = Offset.zero,
    this.direction = Direction.horizontal,
    this.vGap = 10,
    this.hGap = 10,
    this.allowSelectMulti = true,
    this.inactiveStyle = AreaStyle.empty,
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
    value = Command.selectAllLegend;
  }

  void unselect() {
    value = Command.unselectLegend;
  }
}
