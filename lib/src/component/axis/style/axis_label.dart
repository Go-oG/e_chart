// 轴标签相关
import 'package:flutter/painting.dart';

import '../../../functions.dart';
import '../../../model/index.dart';
import '../../../style/index.dart';

class AxisLabel {
  bool show;
  //坐标轴刻度标签的显示间隔，在类目轴中有效。
  // 默认会采用标签不重叠的策略间隔显示标签。默认-1
  // 可以设置成 0 强制显示所有标签。
  // 如果设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推。
  int interval;
  bool inside;
  num rotate;
  num margin;
  num padding;
  bool? showMinLabel;
  bool? showMaxLabel;

  ///是否隐藏重叠的标签
  bool hideOverLap;
  LabelStyle? style;
  LabelStyle? minorStyle;

  Fun2<dynamic, DynamicText>? formatter;
  Fun3<int, int, LabelStyle?>? styleFun;
  Fun3<int, int, LabelStyle?>? minorStyleFun;

  AxisLabel({
    this.show = true,
    this.interval = 0,
    this.inside = false,
    this.rotate = 0,
    this.margin = 8,
    this.padding = 0,
    this.showMinLabel,
    this.showMaxLabel,
    this.hideOverLap = true,
    LabelStyle? style,
    this.formatter,
    this.styleFun,
    this.minorStyle,
    this.minorStyleFun,
  }) {
    if (style != null) {
      this.style = style;
    }
  }

  LabelStyle? getLabelStyle(int index, int maxIndex, AxisTheme theme) {
    if (styleFun != null) {
      return styleFun?.call(index, maxIndex);
    }
    if (style != null) {
      return style;
    }
    if (!theme.showLabel) {
      return null;
    }
    return LabelStyle(textStyle: TextStyle(color: theme.labelColor, fontSize: theme.labelSize.toDouble()));
  }

  LabelStyle? getMinorLabelStyle(int index, int maxIndex, AxisTheme theme) {
    if (minorStyleFun != null) {
      return styleFun?.call(index, maxIndex);
    }
    if (minorStyle != null) {
      return style;
    }
    if (!theme.showLabel) {
      return null;
    }
    return LabelStyle(textStyle: TextStyle(color: theme.minorLabelColor, fontSize: theme.minorLabelSize.toDouble()));
  }
}
