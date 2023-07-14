import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class BaseGridSeries<T extends BaseItemData, P extends BaseGroupData<T>> extends ChartSeries {
  List<P> data;
  Direction direction;
  SelectedMode selectedMode;
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
    super.animation = const AnimatorProps(curve: Curves.easeOutQuart),
    super.backgroundColor,
    super.calendarIndex,
    super.clip,
    super.coordSystem,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.id,
    super.parallelIndex,
    super.polarAxisIndex,
    super.radarIndex,
    super.tooltip,
    super.xAxisIndex,
    super.yAxisIndex,
    super.z,
  });

  DataHelper<T, P, BaseGridSeries>? _helper;

  DataHelper<T, P, BaseGridSeries> get helper {
    _helper ??= DataHelper(this, data);
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
