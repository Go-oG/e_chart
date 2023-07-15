import 'package:flutter/material.dart';
import '../../functions.dart';
import '../../model/enums/trigger.dart';
import '../../model/enums/trigger_on.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../axis/style/axis_pointer.dart';

enum ToolTipOrder {
  seriesAsc,
  seriesDesc,
  valueAsc,
  valueDesc,
}

///提示框
class ToolTip {
   bool show;
   Trigger trigger;
   AxisPointer? axisPointer;
   bool showContent;
   bool alwaysShowContent;
   TriggerOn triggerOn;
   num showDelay;
   num hideDelay;
   bool enterAble;
   bool confine;
   num transitionDuration;

  ///浮层位置，当不设置时跟随鼠标位置
   List<SNumber>? position;

   String? formatter; //字符串模版

   Fun2<num,String>? numberFormatter;
   EdgeInsets padding;
   AreaStyle background;
   LabelStyle labelStyle;
   ToolTipOrder order;

   ToolTip({
    this.show = true,
    this.trigger = Trigger.item,
    this.axisPointer ,
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
