import 'package:flutter/material.dart';

import '../animation/animator_props.dart';
import '../component/tooltip/tool_tip.dart';
import '../model/enums/coordinate.dart';
import '../model/string_number.dart';
import 'chart_notifier.dart';
import 'command.dart';

/// 图表的抽象表示
/// 建议所有的属性都应该为公共且可以更改的
abstract class ChartSeries extends ChartNotifier<Command>{
  ///坐标系系统
  CoordSystem? coordSystem;

  ///坐标轴取值索引(和coordSystem配合实现定位)
  int xAxisIndex;
  int yAxisIndex;
  int polarAxisIndex;
  int calendarIndex;
  int radarIndex;
  int parallelIndex;

  AnimatorProps? animation; //动画
  ToolTip? tooltip;

  ///手势相关
  bool? enableClick;
  bool? enableHover;
  bool? enableDrag;
  bool? enableScale;

  bool clip; // 是否裁剪
  int z; //z轴索引

  ChartSeries({
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    this.polarAxisIndex = 0,
    this.calendarIndex = 0,
    this.radarIndex = 0,
    this.parallelIndex = 0,
    this.animation = const AnimatorProps(),
    this.coordSystem,
    this.tooltip,
    this.enableClick,
    this.enableHover,
    this.enableDrag,
    this.enableScale = false,
    this.z = 0,
    this.clip = true,
  }):super(Command.none);

  void notifyDataSetChange() {
    value=Command.updateData;
  }

  void notifyDataSetInserted() {
    value=Command.insertData;
  }

  void notifyDataSetRemoved() {
    value=Command.deleteData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifySeriesConfigChange() {
    value=Command.configChange;
  }

}

abstract class RectSeries extends ChartSeries {
  /// 定义布局的上下左右间距或者宽高，
  /// 宽高的优先级大于上下间距的优先级(如果定义了)
  SNumber leftMargin;
  SNumber topMargin;
  SNumber rightMargin;
  SNumber bottomMargin;
  SNumber? width;
  SNumber? height;

  RectSeries({
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.width,
    this.height,
    super.coordSystem,
    super.xAxisIndex,
    super.yAxisIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarAxisIndex,
    super.radarIndex,
    super.animation,
    super.tooltip,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.clip,
    super.z,
  });

  /// 从当前
  Rect computePositionBySelf(double left, double top, double right, double bottom) {
    return computePosition(0, 0, right - left, bottom - top);
  }

  /// 计算内容区域
  Rect computePosition(double left, double top, double right, double bottom) {
    double nw = right - left;
    double nh = bottom - top;
    double leftOffset = _computeLeftOffset(nw);
    double topOffset = _computeTopOffset(nh);
    double rightOffset = _computeRightOffset(nw);
    double bottomOffset = _computeBottomOffset(nh);
    return Rect.fromLTRB(left + leftOffset, top + topOffset, right - rightOffset, bottom - bottomOffset);
  }

  double _computeLeftOffset(double width) {
    if (this.width != null) {
      double w = this.width!.convert(width);
      if (w > width) {
        w = width;
      }
      return (width - w) * 0.5;
    }
    return leftMargin.convert(width);
  }

  double _computeTopOffset(double height) {
    if (this.height != null) {
      double h = this.height!.convert(height);
      if (h > height) {
        h = height;
      }
      return (height - h) * 0.5;
    }
    return topMargin.convert(height);
  }

  double _computeRightOffset(double width) {
    if (this.width != null) {
      double w = this.width!.convert(width);
      if (w > width) {
        w = width;
      }
      return (width - w) * 0.5;
    }
    return rightMargin.convert(width);
  }

  double _computeBottomOffset(double height) {
    if (this.height != null) {
      double h = this.height!.convert(height);
      if (h > height) {
        h = height;
      }
      return (height - h) * 0.5;
    }
    return bottomMargin.convert(height);
  }
}
