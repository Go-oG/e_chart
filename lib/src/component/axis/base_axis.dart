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
  ///如果为false 则对齐开始
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
    this.nameGap = 3,
    this.nameStyle = const LabelStyle(),
    this.nameAlign = Align2.end,
    this.niceType = NiceType.n1,
  }) {
    if (axisStyle != null) {
      this.axisStyle = axisStyle;
    }
  }

  ///将指定的参数转换为标度尺
  BaseScale toScale(List<num> range, List<DynamicData> dataSet, bool revertRange) {
    if (revertRange) {
      range = List.from(range.reversed);
    }
    if (isCategoryAxis) {
      if (categoryList.isNotEmpty) {
        return CategoryScale(categoryList, range,categoryCenter);
      }
      List<String> dl = [];
      Set<String> dSet = {};
      for (var data in dataSet) {
        if (data.isString && !dSet.contains(data.data as String)) {
          dl.add(data.data);
          dSet.add(data.data);
        }
      }
      if (dl.isEmpty) {
        throw ChartError('当前提取Category数目为0');
      }
      return CategoryScale(dl, range,categoryCenter);
    }
    List<DynamicData> ds = [...dataSet];

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
    for (var data in ds) {
      if (data.isString) {
        continue;
      }
      if (data.isNum) {
        list.add(data.data);
      } else if (data.isDate) {
        timeList.add(data.data);
      }
    }

    if (type == AxisType.time || timeList.length >= 2) {
      if (timeList.length < 2) {
        DateTime st = timeList.isEmpty ? DateTime.now() : timeList.first;
        DateTime end = st.add(_timeDurationMap[timeType]!);
        timeList.clear();
        timeList.add(st);
        timeList.add(end);
      }
      timeList.sort((a, b) {
        return a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch);
      });
      DateTime start = timeList[0];
      DateTime end = timeList[timeList.length - 1];
      return TimeScale(timeType, [start, end], range);
    }

    if (list.length < 2) {
      if (list.length == 1) {
        list.add(list.first + 100);
      } else {
        list.addAll([0, 100]);
      }
    }

    List<num> v = extremes<num>(list, (p) => p);
    if (type == AxisType.log) {
      List<num> logV = [log(v[0]) / log(logBase), log(v[1]) / log(logBase)];
      v = logV;
    }

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
    if (type == AxisType.log) {
      return LogScale([step.start, step.end], range, step: step.step);
    }
    if (type == AxisType.value) {
      return LinearScale([step.start, step.end], range, step: step.step);
    }
    throw ChartError('现有数据无法推导出Scale');
  }

  List<DynamicText> buildLabels(BaseScale scale) {
    if (scale is CategoryScale) {
      return List.from(scale.ticks.map((e) => DynamicText(e)));
    }
    var formatter = axisStyle.axisLabel.formatter;
    List<DynamicText> ticks = [];
    if (scale is TimeScale) {
      for (var ele in scale.ticks) {
        if (formatter != null) {
          ticks.add(formatter.call(ele.millisecondsSinceEpoch));
        } else {
          ticks.add(DynamicText.fromString(defaultTimeFormat(ele)));
        }
      }
      return ticks;
    }
    if (scale is LinearScale || scale is LogScale) {
      ticks = List.from(scale.ticks.map((e) {
        if (formatter != null) {
          return formatter.call(e);
        } else {
          return DynamicText.fromString(formatNumber(e));
        }
      }));
    }
    return ticks;
  }

  String defaultTimeFormat(DateTime time) {
    if (timeType == TimeType.year) {
      return ('${time.year}');
    }
    if (timeType == TimeType.month) {
      return ('${time.year}-${time.month}');
    }
    if (timeType == TimeType.day) {
      return ('${time.year}-${time.month}-${time.day}');
    }
    if (timeType == TimeType.hour) {
      return ('${time.hour}');
    }
    if (timeType == TimeType.minute) {
      return ('${time.hour}-${time.minute}');
    }
    return ('${time.minute}-${time.second}');
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

Map<TimeType, Duration> _timeDurationMap = {
  TimeType.year: const Duration(days: 365),
  TimeType.month: const Duration(days: 30),
  TimeType.day: const Duration(days: 10),
  TimeType.hour: const Duration(days: 24),
  TimeType.minute: const Duration(days: 60),
  TimeType.sec: const Duration(days: 60),
  TimeType.week: const Duration(days: 7),
};
