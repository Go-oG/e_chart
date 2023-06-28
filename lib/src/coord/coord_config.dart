import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///坐标系
abstract class CoordConfig extends ChartNotifier<Command> {
  late final String id;
  bool show;
  Color? backgroundColor;

  ///手势相关
  bool enableClick;
  bool enableHover;
  bool enableDrag;
  bool enableScale;

  CoordConfig({
    this.show = true,
    String? id,
    this.backgroundColor,
    this.enableClick=false,
    this.enableHover=false,
    this.enableDrag=false,
    this.enableScale = false,
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
