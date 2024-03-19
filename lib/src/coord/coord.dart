import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///坐标系
abstract class Coord extends ChartNotifier<Command> {
  late final String id;
  bool show;
  Color? backgroundColor;

  ///数据框选配置
  Brush? brush;

  ///ToolTip
  ToolTip? toolTip;

  LayoutParams layoutParams = LayoutParams.matchAll();

  bool freeDrag;
  bool freeLongPress;

  Coord({
    this.show = true,
    String? id,
    this.brush,
    this.toolTip,
    this.backgroundColor,
    this.freeDrag = false,
    this.freeLongPress = false,
    LayoutParams? layoutParams,
  }) : super(Command.none) {
    if (layoutParams != null) {
      this.layoutParams = layoutParams;
    }
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  CoordType get coordSystem;

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifyCoordConfigChange() {
    value = Command.configChange;
  }

  CoordLayout? toCoord(Context context) {
    return null;
  }
}
