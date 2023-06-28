// 轴标签相关

import '../../style/label.dart';

class AxisLabel {
  bool show;

  //坐标轴刻度标签的显示间隔，在类目轴中有效。
  // 默认会采用标签不重叠的策略间隔显示标签。默认-1
  // 可以设置成 0 强制显示所有标签。
  // 如果设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推。
  int interval;

  bool inside;

  double rotate;

  double margin;

  bool? showMinLabel;
  bool? showMaxLabel;

  ///是否隐藏重叠的标签
  bool hideOverLap;
  LabelStyle labelStyle;

  AxisLabel({
    this.show = true,
    this.interval = 0,
    this.inside = false,
    this.rotate = 0,
    this.margin = 8,
    this.showMinLabel,
    this.showMaxLabel,
    this.hideOverLap = true,
    this.labelStyle = const LabelStyle(),
  });
}
