import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/brush/brush.dart';
import 'package:flutter/rendering.dart';

///坐标系
abstract class Coord extends ChartNotifier<Command> {
  late final String id;
  bool show;
  Color? backgroundColor;

  ///数据框选配置
  Brush? brush;
  SNumber? width;
  SNumber? height;
  EdgeInsets margin = const EdgeInsets.all(0);
  EdgeInsets padding = const EdgeInsets.all(16);

  ///手势相关
  bool enableClick;
  bool enableHover;
  bool enableDrag;
  bool enableScale;

  Coord({
    this.show = true,
    String? id,
    EdgeInsets? margin,
    EdgeInsets? padding,
    SNumber? width,
    SNumber? height,
    this.brush,
    this.backgroundColor,
    this.enableClick = true,
    this.enableHover = true,
    this.enableDrag = true,
    this.enableScale = false,
  }) : super(Command.none) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    if (margin != null) {
      this.margin = margin;
    }
    if (padding != null) {
      this.padding = padding;
    }
    if (width != null) {
      this.width = width;
    }
    if (height != null) {
      this.height = height;
    }
  }

  CoordSystem get coordSystem;

  LayoutParams toLayoutParams() {
    return LayoutParams(
      width ?? const SNumber(LayoutParams.matchParent, false),
      height ?? const SNumber(LayoutParams.matchParent, false),
      padding: padding,
      margin: margin,
    );
  }

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifyCoordConfigChange() {
    value = Command.configChange;
  }
}
