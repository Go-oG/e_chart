import 'dart:math' as math;
import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:chart_xutil/chart_xutil.dart';

abstract class BaseAxis {
  bool show;
  AxisType type;

  DynamicText? name;
  Align2 nameAlign;
  num nameGap;
  LabelStyle nameStyle;

  ///类目数据
  List<String> categoryList;

  ///当坐标轴为类目轴时，类别是否对齐中间
  ///如果为false 则对齐开始 默认为true
  bool categoryCenter;

  //只在时间轴下使用
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
  NiceType niceType;

  //是否翻转坐标轴数据
  bool inverse;

  ///样式、交互相关
  bool silent;
  AxisStyle axisStyle = AxisStyle();

  BaseAxis({
    this.show = true,
    this.name,
    this.type = AxisType.value,
    this.categoryList = const [],
    this.categoryCenter = true,
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
    this.nameGap = 8,
    this.nameStyle = const LabelStyle(),
    this.nameAlign = Align2.end,
    this.niceType = NiceType.n1,
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
    if (axis.nameAlign == Align2.center) {
      continue;
    }
    Size size = axis.name == null ? Size.zero : axis.nameStyle.measure(axis.name!, maxWidth: maxWidth.toDouble());
    double mw;
    double mh;
    if (direction == Direction.horizontal) {
      mw = math.max(firstSize.width, size.width);
      mh = math.max(firstSize.height, size.height + axis.nameGap);
    } else {
      mw = math.max(firstSize.width, size.width + axis.nameGap);
      mh = math.max(firstSize.height, size.height);
    }
    if (axis.nameAlign == Align2.start) {
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

