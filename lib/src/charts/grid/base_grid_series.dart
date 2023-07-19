import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class BaseGridSeries<T extends BaseItemData, P extends BaseGroupData<T>> extends ChartSeries {
  List<P> data;

  ///指示图形排列方式
  Direction direction;

  SelectedMode selectedMode;

  ///该动画样式只在柱状图中使用
  GridAnimatorStyle animatorStyle;

  // 是否启用图例hover的联动高亮
  bool legendHoverLink;

  // 是否启用实时排序
  bool realtimeSort;

  BaseGridSeries(
    this.data, {
    this.direction = Direction.vertical,
    this.selectedMode = SelectedMode.group,
    this.animatorStyle = GridAnimatorStyle.expand,
    this.legendHoverLink = true,
    this.realtimeSort = false,
    super.animation = const AnimatorAttrs(
        curve: Curves.easeOutQuart, updateDuration: Duration(milliseconds: 800), duration: Duration(milliseconds: 2000)),
    super.backgroundColor,
    super.clip,
    super.coordSystem = CoordSystem.grid,
    super.xAxisIndex,
    super.yAxisIndex,
    super.polarAxisIndex,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.id,
    super.tooltip,
    super.z,
  }) : super(radarIndex: -1, parallelIndex: -1, calendarIndex: -1);

  DataHelper<T, P, BaseGridSeries>? _helper;

  DataHelper<T, P, BaseGridSeries> get helper {
    _helper ??= DataHelper(this, data, direction);
    return _helper!;
  }

  @override
  void notifySeriesConfigChange() {
    _helper = null;
    super.notifySeriesConfigChange();
  }

  @override
  void notifyUpdateData() {
    _helper = null;
    super.notifyUpdateData();
  }
}

///动画样式
enum GridAnimatorStyle { expand, originExpand }
