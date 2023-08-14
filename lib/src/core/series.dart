import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 图表的抽象表示
/// 建议所有的属性都应该为公共且可以更改的
abstract class ChartSeries extends ChartNotifier<Command> {
  late final String id;
  int seriesIndex = -1;
  String name;

  ///坐标系系统
  CoordType? coordType;

  ///坐标轴取值索引(和coordSystem配合实现定位)
  int gridIndex;
  int polarIndex;
  int calendarIndex;
  int radarIndex;
  int parallelIndex;

  Color? backgroundColor;
  AnimatorAttrs? animation; //动画
  ToolTip? tooltip;

  bool clip; // 是否裁剪
  int z; //z轴索引

  ChartSeries(
      {this.gridIndex = 0,
      this.polarIndex = 0,
      this.calendarIndex = 0,
      this.radarIndex = 0,
      this.parallelIndex = 0,
      this.animation = const AnimatorAttrs(),
      this.coordType,
      this.tooltip,
      this.z = 0,
      this.clip = true,
      this.backgroundColor,
      this.name = '',
      String? id})
      : super(Command.none) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifySeriesConfigChange() {
    value = Command.configChange;
  }

  ChartView? toView() {
    return null;
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
    super.coordType,
    super.gridIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.animation,
    super.backgroundColor,
    super.tooltip,
    super.clip,
    super.z,
    super.id,
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
