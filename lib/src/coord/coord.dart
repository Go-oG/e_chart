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

  LayoutParams layoutParams;

  Coord({
    this.show = true,
    String? id,
    this.layoutParams = const LayoutParams.matchAll(padding: EdgeInsets.all(32)),
    this.brush,
    this.toolTip,
    this.backgroundColor,
  }) : super(Command.none) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  CoordSystem get coordSystem;

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifyCoordConfigChange() {
    value = Command.configChange;
  }
}
