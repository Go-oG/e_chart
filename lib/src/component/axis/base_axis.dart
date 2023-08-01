import 'dart:math' as math;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

abstract class BaseAxis {
  bool show;
  AxisType type;

  ///类目轴相关配置
  ///当坐标轴为类目轴时，标签是否对齐中间 如果为false 则对齐开始位置，默认为true
  bool categoryCenter;

  ///类目数据如果为空，则从给定的坐标中获取
  List<String> categoryList;

  ///只在时间轴下使用
  TimeType timeType;
  Pair<DateTime>? timeRange;
  Fun2<DateTime, DynamicText>? timeFormatFun;

  ///数值轴相关
  num min;
  num? max;
  bool start0;
  int splitNumber;
  num minInterval;
  num? maxInterval;
  num? interval;
  num logBase;

  ///在多个轴为数值轴的时候，可以开启该配置项自动对齐刻度。
  ///只对'value'和'log'类型的轴有效。
  bool alignTicks;

  ///是否翻转坐标轴数据
  bool inverse;

  ///样式、交互相关
  bool silent;
  AxisStyle axisStyle = AxisStyle();
  AxisName? axisName;

  BaseAxis({
    this.show = true,
    this.axisName,
    this.type = AxisType.value,
    this.categoryList = const [],
    this.categoryCenter = true,
    this.alignTicks = true,
    this.timeType = TimeType.day,
    this.timeFormatFun,
    this.inverse = false,
    this.min = 0,
    this.max,
    this.start0 = true,
    this.splitNumber = 5,
    this.minInterval = 0,
    this.maxInterval,
    this.interval,
    this.logBase = 10,
    this.silent = false,
    AxisStyle? axisStyle,
    this.timeRange,
  }) {
    if (axisStyle != null) {
      this.axisStyle = axisStyle;
    }
  }

  bool get isCategoryAxis => categoryList.isNotEmpty || type == AxisType.category;

  bool get isTimeAxis => timeRange != null || type == AxisType.time;

  bool get isLogAxis => type == AxisType.log;
}

///给定坐标轴集和方向
///测量单个坐标轴名占用的最大宽度和高度
///当 对齐为 center时 直接返回0
List<Size> measureAxisNameTextMaxSize(Iterable<BaseAxis> axisList, Direction direction, num maxWidth) {
  Size firstSize = Size.zero;
  Size lastSize = Size.zero;
  for (var axis in axisList) {
    final axisName = axis.axisName;
    if (axisName == null) {
      continue;
    }
    var align = axisName.align;
    var name = axisName.name;
    var nameGap = axisName.nameGap;
    if (align == Align2.center) {
      continue;
    }
    Size size = axisName.labelStyle.measure(name, maxWidth: maxWidth.toDouble());
    double mw;
    double mh;
    if (direction == Direction.horizontal) {
      mw = math.max(firstSize.width, size.width);
      mh = math.max(firstSize.height, size.height + nameGap);
    } else {
      mw = math.max(firstSize.width, size.width + nameGap);
      mh = math.max(firstSize.height, size.height);
    }
    if (align == Align2.start) {
      firstSize = Size(mw, mh);
    } else {
      lastSize = Size(mw, mh);
    }
  }
  return [firstSize, lastSize];
}

enum AxisType {
  value,
  category,
  time,
  log,
}

///时间分割类型
enum TimeType {
  year,
  month,
  day,
  hour,
  minute,
  sec,
  week,
}
