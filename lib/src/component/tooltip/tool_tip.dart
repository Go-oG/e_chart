import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/enums/trigger.dart';
import '../../model/enums/trigger_on.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../axis/axis_pointer.dart';

enum ToolTipOrder {
  seriesAsc,
  seriesDesc,
  valueAsc,
  valueDesc,
}

///提示框
class ToolTip {
  final bool show;
  final Trigger trigger;
  final AxisPointer axisPointer;
  final bool showContent;
  final bool alwaysShowContent;
  final TriggerOn triggerOn;
  final num showDelay;
  final num hideDelay;
  final bool enterAble;
  final bool confine;
  final num transitionDuration;

  ///浮层位置，当不设置时跟随鼠标位置
  final List<SNumber>? position;

  final String? formatter; //字符串模版

  final FormatterFun? numberFormatter;
  final EdgeInsets padding;
  final AreaStyle background;
  final LabelStyle labelStyle;
  final ToolTipOrder order;

  const ToolTip({
    this.show = true,
    this.trigger = Trigger.item,
    this.axisPointer = const AxisPointer(),
    this.showContent = true,
    this.alwaysShowContent = false,
    this.triggerOn = TriggerOn.moveAndClick,
    this.showDelay = 0,
    this.hideDelay = 100,
    this.enterAble = true,
    this.confine = false,
    this.transitionDuration = 400,
    this.position,
    this.formatter,
    this.numberFormatter,
    this.order = ToolTipOrder.seriesAsc,
    this.background = const AreaStyle(),
    this.padding = EdgeInsets.zero,
    this.labelStyle = const LabelStyle(),
  });
}
