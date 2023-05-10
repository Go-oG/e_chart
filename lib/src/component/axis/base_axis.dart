import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:chart_xutil/chart_xutil.dart';

import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../../model/range.dart';
import '../../style/label.dart';
import '../scale/nice_scale.dart';
import '../scale/scale_base.dart';
import '../scale/scale_category.dart';
import '../scale/scale_linear.dart';
import '../scale/scale_time.dart';
import 'axis_line.dart';

enum AxisType {
  value,
  category,
  time,
  log,
}

///时间分割类型
enum TimeSplitType {
  year,
  month,
  day,
  hour,
  minute,
  sec,
}

abstract class BaseAxis {
  final bool show;
  final AxisType type;
  final String name;
  final Align2 nameAlign;
  final num nameGap;
  final LabelStyle nameStyle;

  //只有当轴类型为类目轴才有效
  final List<String> categoryList;

  //只在时间轴下使用
  final TimeSplitType timeSplitType;
  final Pair<DateTime>? timeRange;
  final FormatterFun<DateTime>? timeFormatFun;

  final bool inverse;

  ///数值轴相关
  final num min;
  final num? max;
  ///是否是脱离 0 值比例。设置成 true 后坐标刻度不会强制包含零刻度
  final bool start0;
  final int splitNumber;
  final num minInterval;
  final num? maxInterval;
  final num? interval;
  final num logBase;

  final NiceType niceType;
  ///样式、交互相关
  final bool silent;
  final AxisLine axisLine;
  final FormatterFun<num>? formatFun;

  const BaseAxis({
    this.show = true,
    this.name = '',
    this.type = AxisType.value,
    this.categoryList = const [],
    this.timeSplitType = TimeSplitType.day,
    this.timeFormatFun,
    this.inverse = false,
    this.min = 0,
    this.max,
    this.start0 = false,
    this.splitNumber = 5,
    this.minInterval = 0,
    this.maxInterval,
    this.interval,
    this.logBase = 10,
    this.silent = false,
    this.axisLine = const AxisLine(),
    this.formatFun,
    this.timeRange,
    this.nameGap = 3,
    this.nameStyle = const LabelStyle(),
    this.nameAlign = Align2.end,
    this.niceType = NiceType.n1,
  });

  BaseScale toScale(num rangeStart, num rangeEnd, [List<DynamicData>? dataSet]) {
    List<num> rangeValue = [rangeStart, rangeEnd];
    if (category) {
      return CategoryScale(categoryList, rangeValue, inverse);
    }
    List<DynamicData> ds = [];
    if (dataSet != null) {
      ds.addAll(dataSet);
    }
    ds.add(DynamicData(min));
    if (max != null) {
      ds.add(DynamicData(max));
    }
    if (timeRange != null) {
      ds.add(DynamicData(timeRange!.start));
      ds.add(DynamicData(timeRange!.end));
    }

    List<num> list = [];
    List<DateTime> timeList = [];
    if (dataSet != null) {
      for (var data in dataSet) {
        if (data.isString) {
          continue;
        }
        if (data.isNum) {
          list.add(data.data);
        } else if (data.isDate) {
          timeList.add(data.data);
        }
      }
    }

    if (type == AxisType.time) {
      if (timeList.isEmpty) {
        throw FlutterError('现有数据无法推导出坐标范围');
      }
      timeList.sort((a, b) {
        return a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch);
      });
      DateTime start = timeList[0];
      DateTime end = timeList[timeList.length - 1];
      return TimeScale(timeSplitType, [start, end], rangeValue, inverse);
    }

    if (type == AxisType.value || type == AxisType.log) {
      List<num> v = extremes<num>(list, (p) => p);
      NiceScale step = NiceScale.nice(
        v[0],
        v[1],
        splitNumber,
        minInterval: minInterval,
        maxInterval: maxInterval,
        interval: interval,
        start0: start0,
        type: niceType,
      );
      return LinearScale([step.start, step.end], rangeValue, inverse, step.tickCount);
    }

    throw FlutterError('现有数据无法推导出Scale');
  }

  List<String> buildTicks(BaseScale scale) {
    if (scale is CategoryScale) {
      return scale.domain;
    }
    List<String> ticks = [];
    if (scale is TimeScale) {
      for (var ele in scale.ticks) {
        if (formatFun != null) {
          ticks.add(formatFun!.call(ele.millisecondsSinceEpoch));
        } else {
          ticks.add(defaultTimeFormat(ele));
        }
      }
      return ticks;
    }
    if (scale is LinearScale) {
      int count = scale.tickCount;
      num interval = (scale.domain.last - scale.domain.first) / count;
      for (int i = 0; i <= count; i += 1) {
        num v = scale.domain.first + i * interval;
        if (formatFun != null) {
          ticks.add(formatFun!.call(v));
        } else {
          ticks.add(formatNumber(v));
        }
      }
    }
    return ticks;
  }

  String defaultTimeFormat(DateTime time) {
    if (timeSplitType == TimeSplitType.year) {
      return ('${time.year}');
    }
    if (timeSplitType == TimeSplitType.month) {
      return ('${time.year}-${time.month}');
    }
    if (timeSplitType == TimeSplitType.day) {
      return ('${time.year}-${time.month}-${time.day}');
    }
    if (timeSplitType == TimeSplitType.hour) {
      return ('${time.hour}');
    }
    if (timeSplitType == TimeSplitType.minute) {
      return ('${time.hour}-${time.minute}');
    }
    return ('${time.minute}-${time.second}');
  }

  bool get category => categoryList.isNotEmpty;
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
    Size size = axis.nameStyle.measure(axis.name, maxWidth: maxWidth.toDouble());
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
