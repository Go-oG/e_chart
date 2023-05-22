import 'package:flutter/material.dart';

import '../animation/animator_props.dart';
import '../component/tooltip/tool_tip.dart';
import '../functions.dart';
import '../model/enums/coordinate.dart';
import '../model/string_number.dart';

/// 图表的抽象表示
/// 建议所有的属性都应该为公共且可以更改的
abstract class ChartSeries {
  //用于进行刷新相关的配置
  final ValueNotifier<Command> _notifier = ValueNotifier(Command(Command.none));
  final Map<ValueCallback<Command>, VoidCallback> _listenerMap = {};

  ///坐标系系统
  CoordSystem? coordSystem;

  ///坐标轴取值(和coordSystem配合实现定位)
  ///(默认的所有坐标轴开始都是为0)
  int xAxisIndex;
  int yAxisIndex;
  int polarAxisIndex;
  int calendarIndex;
  int radarIndex;
  int parallelIndex;

  AnimatorProps? animation; //动画
  ToolTip? tooltip;
  bool touch; //是否允许交互
  bool clip; // 是否裁剪
  int z; //z轴索引

  ChartSeries({
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    this.polarAxisIndex = 0,
    this.calendarIndex = 0,
    this.radarIndex = 0,
    this.parallelIndex = 0,
    this.animation=const AnimatorProps(),
    this.touch = true,
    this.z = 0,
    this.clip = true,
    this.coordSystem,
    this.tooltip,
  });

  void notifyDataSetChange([bool relayout = false]) {
    if (relayout) {
      _notifier.value = Command(Command.reLayout);
      return;
    }
    _notifier.value = Command(Command.updateData);
  }

  void notifyDataSetInserted([bool relayout = false]) {
    if (relayout) {
      _notifier.value = Command(Command.reLayout);
      return;
    }
    _notifier.value = Command(Command.insertData);
  }

  void notifyDataSetRemoved([bool relayout = false]) {
    if (relayout) {
      _notifier.value = Command(Command.reLayout);
      return;
    }
    _notifier.value = Command(Command.deleteData);
  }

  void change(Command command) {
    ///为了避免外部缓存了数据
    _notifier.value = Command(command.code);
  }

  /// 下面是对ValueNotifier的简单封装
  void addListener(ValueCallback<Command> callback) {
    if (_listenerMap[callback] != null) {
      _notifier.removeListener(() {
        _listenerMap[callback]!;
      });
    }
    voidCallback() {
      callback.call(_notifier.value);
    }
    _listenerMap[callback] = voidCallback;
    _notifier.addListener(voidCallback);
  }

  void removeListener(ValueCallback<Command> callback) {
    VoidCallback? voidCallback = _listenerMap.remove(callback);
    if (voidCallback != null) {
      _notifier.removeListener(voidCallback);
    }
  }

  bool hasListeners() {
    return _notifier.hasListeners;
  }

  void dispose() {
    _listenerMap.clear();
    _notifier.dispose();
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
    super.clip,
    super.touch,
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

  final int code;

  Command(this.code);
}
