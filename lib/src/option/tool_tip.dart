import 'package:e_chart/e_chart.dart';
import 'package:e_chart/e_chart.dart' as e;
import 'package:flutter/material.dart';

///提示框
class ToolTip extends ChartNotifier2 {
  bool show;
  Trigger trigger;
  TriggerOn triggerOn;
  bool alwaysShowContent;

  ///鼠标是否可进入提示框浮层中，默认为false，如需详情内交互，如添加链接，按钮，可设置为 true。
  bool enterAble;

  ///是否将 tooltip 框限制在图表的区域内
  bool confine;

  ///提示框浮层的移动动画过渡时间 设置为<=0 的时候会紧跟着鼠标移动
  num transitionDuration;
  num? minWidth;
  num? minHeight;
  num? maxWidth;
  num? maxHeight;

  ///浮层位置，当不设置时跟随鼠标位置
  List<SNumber>? position;
  EdgeInsets padding;
  e.Corner corner = const e.Corner(8, 8, 8, 8);

  AreaStyle backgroundStyle = const AreaStyle(
    color: Color(0xFFFFFFFF),
    shadow: [BoxShadow(color: Colors.black26, blurRadius: 8, blurStyle: BlurStyle.solid)],
  );
  LineStyle? borderStyle;
  LabelStyle labelStyle;
  ToolTipOrder order;

  ToolTip({
    this.show = true,
    this.trigger = Trigger.item,
    this.alwaysShowContent = false,
    this.triggerOn = TriggerOn.moveAndClick,
    this.enterAble = false,
    this.confine = false,
    this.transitionDuration = 400,
    this.position,
    this.order = ToolTipOrder.seriesAsc,
    e.Corner? corner,
    AreaStyle? backgroundStyle,
    this.borderStyle,
    this.padding = const EdgeInsets.all(5),
    this.labelStyle = const LabelStyle(),
    this.minHeight,
    this.minWidth = 300,
    this.maxHeight = 400,
    this.maxWidth,
  }) {
    if (backgroundStyle != null) {
      this.backgroundStyle = backgroundStyle;
    }
    if (corner != null) {
      this.corner = corner;
    }
  }
}

enum ToolTipOrder {
  seriesAsc,
  seriesDesc,
  valueAsc,
  valueDesc,
}
