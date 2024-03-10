import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 图表的抽象表示
/// 建议所有的属性都应该为公共且可以更改的
///每个图表必须要有一个Series
abstract class ChartSeries extends ChartNotifier<Command> {
  late final String id;

  ///Series的索引 在Context中进行分配
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
  AnimatorOption? animation; //动画
  ToolTip? tooltip;

  bool clip; // 是否裁剪
  bool useSingleLayer;

  ChartSeries({
    this.gridIndex = 0,
    this.polarIndex = 0,
    this.calendarIndex = 0,
    this.radarIndex = 0,
    this.parallelIndex = 0,
    this.animation,
    this.coordType,
    this.tooltip,
    this.clip = true,
    this.backgroundColor,
    this.name = '',
    String? id,
    this.useSingleLayer = false,
  }) : super(Command.none) {
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

  ///通知视图当前Series 配置发生了变化(包含了数据变化)
  /// 它会触发整个View重新走一遍构造流程
  /// 如果仅仅只是数据发生变化了建议使用 [notifyUpdateData]
  void notifyConfigChange() {
    value = Command.configChange;
  }

  ///返回承载该Series的渲染视图
  ///如果返回null,那么将会调用[SeriesFactory]的相关方法
  ///来创建视图，如果无法创建视图则会抛错
  ChartView? toView() {
    return null;
  }

  ///每个Series必须返回一个图例数据集
  ///以便在需要显示Legend时能够获取到数据
  List<LegendItem> getLegendItem(Context context);

  SeriesType get seriesType;

  ///分配样式索引
  int onAllocateStyleIndex(int start);

  ///获取动画参数
  ///[threshold]动画执行上限,超过该值则不执行 设置为<=0则不执行任何动画
  AnimatorOption? getAnimation(LayoutType type, [int threshold = -1]) {
    var attr = animation;
    if (type == LayoutType.none || attr == null) {
      return null;
    }
    if (threshold > 0 && threshold > attr.threshold && attr.threshold > 0) {
      return null;
    }
    if (type == LayoutType.layout) {
      if (attr.duration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    if (type == LayoutType.update) {
      if (attr.duration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    return null;
  }

  @override
  void dispose() {
    animation = null;
    super.dispose();
  }
}
