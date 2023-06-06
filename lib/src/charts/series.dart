import 'package:flutter/material.dart';

import '../animation/animator_props.dart';
import '../component/tooltip/tool_tip.dart';
import '../functions.dart';
import '../model/enums/coordinate.dart';
import '../model/string_number.dart';

/// 图表的抽象表示
/// 建议所有的属性都应该为公共且可以更改的
abstract class ChartSeries {
  ///用于通知View数据发生改变或者需要重新布局等命令
  final ValueNotifier<Command> _notifier = ValueNotifier(Command(Command.none));
  final Set<ValueCallback<Command>> _listenerSet = {};

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
  }) {
    _notifier.addListener(() {
      var v = _notifier.value;
      try {
        for (var c in _listenerSet) {
          c.call(v);
        }
      } catch (_) {}
    });
  }

  void notifyDataSetChange() {
    notifyChange(Command.updateData);
  }

  void notifyDataSetInserted() {
    notifyChange(Command.insertData);
  }

  void notifyDataSetRemoved() {
    notifyChange(Command.deleteData);
  }

  ///通知视图当前Series 配置发生了变化
  void notifySeriesConfigChange() {
    notifyChange(Command.configChange);
  }

  ///发送通知
  void notifyChange(int code) {
    ///为了避免外部缓存了数据
    _notifier.value = Command(code);
  }

  /// 下面是对ValueNotifier的简单封装
  void addListener(ValueCallback<Command> callback) {
    if (_listenerSet.contains(callback)) {
      return;
    }
    _listenerSet.add(callback);
  }

  void removeListener(ValueCallback<Command> callback) {
    _listenerSet.remove(callback);
  }

  bool hasListeners() {
    return _listenerSet.isNotEmpty;
  }

  void dispose() {
    _notifier.dispose();
    _listenerSet.clear();
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

class Command {
  static const int none = 0;
  static const int invalidate = -1;
  static const int reLayout = -2;
  static const int insertData = -3;
  static const int deleteData = -4;
  static const int updateData = -5;
  static const int configChange = -6;

  final int code;

  Command(this.code);
}
