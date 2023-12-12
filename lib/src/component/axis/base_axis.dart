import 'dart:math' as math;
import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

abstract class BaseAxis extends ChartNotifier2 {
  bool show;
  late String id;
  AxisType type;

  ///类目轴相关配置
  ///当坐标轴为类目轴时，标签是否对齐中间 如果为false 则对齐开始位置，默认为true
  bool categoryCenter;

  ///类目数据如果为空，则从数据源中获取
  List<String> categoryList;

  ///只在时间轴下使用
  TimeType timeType;
  Pair<DateTime>? timeRange;

  ///数值轴相关
  num? min;
  num? max;

  int splitNumber;
  num minInterval;
  num? maxInterval;
  num? interval;
  num logBase;

  ///是否翻转坐标轴数据
  bool inverse;

  ///================样式相关-=================

  ///在多个轴为数值轴的时候，可以开启该配置项自动对齐刻度。
  ///只对'value'和'log'类型的轴有效。
  bool alignTicks;

  AxisName? axisName;

  late AxisLine axisLine = AxisLine();
  late AxisLabel axisLabel = AxisLabel();
  late AxisTick axisTick = AxisTick();
  late SplitLine splitLine = SplitLine();
  late SplitArea splitArea = SplitArea();

  ///坐标轴指示器
  AxisPointer? axisPointer;

  BaseAxis({
    String? id,
    this.show = true,
    this.type = AxisType.value,
    this.categoryList = const [],
    this.categoryCenter = true,
    this.alignTicks = true,
    this.timeType = TimeType.day,
    this.timeRange,
    this.min,
    this.max,
    this.splitNumber = 5,
    this.minInterval = 0,
    this.maxInterval,
    this.interval,
    this.logBase = 10,
    this.inverse = false,
    this.axisName,
    AxisLine? axisLine,
    AxisTick? axisTick,
    AxisLabel? axisLabel,
    SplitLine? splitLine,
    SplitArea? splitArea,
    this.axisPointer,
  }) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = randomId();
    }
    if (axisLine != null) {
      this.axisLine = axisLine;
    }
    if (axisLabel != null) {
      this.axisLabel = axisLabel;
    }
    if (splitLine != null) {
      this.splitLine = splitLine;
    }
    if (splitArea != null) {
      this.splitArea = splitArea;
    }
    if (axisTick != null) {
      this.axisTick = axisTick;
    }
  }

  bool get isCategoryAxis => categoryList.isNotEmpty || type == AxisType.category;

  bool get isTimeAxis => timeRange != null || type == AxisType.time;

  bool get isLogAxis => type == AxisType.log;

  DynamicText formatData(dynamic data) {
    if (data == null) {
      return DynamicText.empty;
    }
    var formatter = axisLabel.formatter;
    if (formatter != null) {
      return formatter.call(data);
    }
    if (data is DynamicText) {
      return data;
    }
    if (data is String) {
      return DynamicText(data);
    }

    if (data is DateTime) {
      return defaultTimeFormat(timeType, data).toText();
    }
    if (data is num) {
      return DynamicText.fromString(formatNumber(data));
    }
    return DynamicText.empty;
  }

  BaseScale toScale(List<num> range, List<dynamic> dataSet, int? splitCount, [double scaleFactor = 1]) {
    if (isCategoryAxis) {
      List<String> sl = List.from(categoryList);
      if (sl.isEmpty) {
        Set<String> dSet = {};
        for (var data in dataSet) {
          if (data is String && !dSet.contains(data)) {
            sl.add(data);
            dSet.add(data);
          }
        }
      }

      if (sl.isEmpty) {
        throw ChartError('当前提取Category数目为0');
      }
      if (inverse) {
        return CategoryScale(List.from(sl.reversed), range, categoryCenter);
      }
      return CategoryScale(sl, range, categoryCenter);
    }

    List<dynamic> ds = [...dataSet];
    if (min != null) {
      ds.add(min);
    }
    if (max != null) {
      ds.add(max);
    }
    if (timeRange != null) {
      ds.add(timeRange!.start);
      ds.add(timeRange!.end);
    }

    List<num> list = [];
    List<DateTime> timeList = [];
    for (var data in ds) {
      if (data is String) {
        continue;
      }
      if (data is num) {
        list.add(data);
      } else if (data is DateTime) {
        timeList.add(data);
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
      List<DateTime> resultList = [start, end];
      if (inverse) {
        resultList = List.from(resultList.reversed);
      }
      return TimeScale(timeType, resultList, range);
    }
    list.sort();

    if (list.isEmpty) {
      list.addAll([0, 100]);
    } else if (list.length == 1) {
      if (list.first != 0) {
        list.add(0);
      } else {
        list.add(100);
      }
    }

    List<num> v = extremes<num>(list, (p) => p);
    if (type == AxisType.log) {
      num base = log(logBase);
      List<num> logV = [log(v[0]) / base, log(v[1]) / base];
      v = logV;
    }
    if (scaleFactor < 1) {
      scaleFactor = 1;
    }
    int spn = splitNumber;
    if (spn < 2) {
      spn = 2;
    }
    spn = (spn * scaleFactor).round();
    if (splitCount != null) {
      spn = splitCount;
    }

    var step = NiceScale.nice(
      v[0],
      v[1],
      spn,
      minInterval: minInterval,
      maxInterval: maxInterval,
      interval: interval,
      start0: false,
      forceSplitNumber: splitCount != null,
    );

    List<num> resultList = [step.start, step.end];
    if (inverse) {
      resultList = List.from(resultList.reversed);
    }
    if (type == AxisType.log) {
      return LogScale(resultList, range, step: step.step);
    }
    if (type == AxisType.value) {
      return LinearScale(resultList, range, step: step.step);
    }
    throw ChartError('现有数据无法推导出Scale');
  }

  static String defaultTimeFormat(TimeType timeType, DateTime time) {
    if (timeType == TimeType.year) {
      return ('${time.year}');
    }
    if (timeType == TimeType.month) {
      if (time.month == 1) {
        return ('${time.year}-${time.month}');
      }
      return ('${time.month}');
    }

    if (timeType == TimeType.day) {
      if (time.month == 1 && time.day == 1) {
        return '${time.year}-${time.month}-${time.day}';
      }
      return '${time.month}-${time.day}';
    }

    if (timeType == TimeType.hour) {
      return ('${time.hour}');
    }
    if (timeType == TimeType.minute) {
      return ('${time.hour}-${time.minute}');
    }
    return ('${time.minute}-${time.second}');
  }

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


Map<TimeType, Duration> _timeDurationMap = {
  TimeType.year: const Duration(days: 365),
  TimeType.month: const Duration(days: 30),
  TimeType.day: const Duration(days: 10),
  TimeType.hour: const Duration(days: 24),
  TimeType.minute: const Duration(days: 60),
  TimeType.sec: const Duration(days: 60),
  TimeType.week: const Duration(days: 7),
};
