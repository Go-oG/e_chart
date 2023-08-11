import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L extends AxisAttrs, R extends AxisLayoutResult, C extends CoordLayout>
    extends ChartNotifier<Command> {
  final int axisIndex;
  final C coord;
  final Context context;
  final T axis;
  late L attrs;
  late BaseScale scale;
  late R layoutResult;

  late final AxisTitleNode titleNode;

  BaseAxisImpl(this.context, this.coord, this.axis, {this.axisIndex = 0}) : super(Command.none) {
    titleNode = AxisTitleNode(axis.axisName);
  }

  void doMeasure(double parentWidth, double parentHeight) {}

  void doLayout(L attrs, List<dynamic> dataSet) {
    this.attrs = attrs;
    scale = onBuildScale(attrs, dataSet);
    titleNode.config = onLayoutAxisName();
    layoutResult = onLayout(attrs, scale);
  }

  void onAttrsChange(L attrs) {
    this.attrs = attrs;
    List<dynamic> dl = scale.domain;
    scale = onBuildScale(attrs, dl);
    titleNode.config = onLayoutAxisName();
    layoutResult = onLayout(attrs, scale);
  }

  R onLayout(L attrs, BaseScale scale);

  BaseScale onBuildScale(L attrs, List<dynamic> dataSet);

  TextDrawInfo onLayoutAxisName();

  void debugDraw(Canvas canvas, Offset offset, {Color color = Colors.deepPurple, bool fill = true, num r = 6}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(offset, r.toDouble(), mPaint);
  }

  void debugDrawRect(Canvas canvas, Rect rect, {Color color = Colors.deepPurple, bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawRect(rect, mPaint);
  }

  final stopWatch = Stopwatch();

  void draw(Canvas canvas, Paint paint, Rect coord) {
    Offset offset = this.coord.getTranslation();
    onDrawAxisSplitArea(canvas, paint, offset);
    onDrawAxisSplitLine(canvas, paint, offset);
    onDrawAxisTick(canvas, paint, offset);
    onDrawAxisLabel(canvas, paint, offset);
    onDrawAxisLine(canvas, paint, offset);
    onDrawAxisName(canvas, paint);
  }

  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Offset scroll) {}

  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Offset scroll) {}

  void onDrawAxisName(Canvas canvas, Paint paint) {
    var name = titleNode.name?.name;
    if (name == null || name.isEmpty) {
      return;
    }
    axis.axisName?.labelStyle.draw(canvas, paint, name, titleNode.config);
  }

  void onDrawAxisLine(Canvas canvas, Paint paint, Offset scroll) {}

  void onDrawAxisTick(Canvas canvas, Paint paint, Offset scroll) {}

  void onDrawAxisLabel(Canvas canvas, Paint paint, Offset scroll) {}

  ///绘制坐标轴指示器，该方法在[draw]之后调用
  void onDrawAxisPointer(Canvas canvas, Paint paint, Offset offset) {}

  List<DynamicText> obtainLabel() {
    if (scale is CategoryScale) {
      return List.from(scale.labels.map((e) => DynamicText(e)));
    }
    var formatter = axis.axisLabel.formatter;
    List<DynamicText> labels = [];
    if (scale is TimeScale) {
      for (var ele in scale.labels) {
        if (formatter != null) {
          labels.add(formatter.call(ele.millisecondsSinceEpoch));
        } else {
          labels.add(DynamicText.fromString(defaultTimeFormat(axis.timeType, ele)));
        }
      }
      return labels;
    }
    if (scale is LinearScale || scale is LogScale) {
      labels = List.from(scale.labels.map((e) {
        if (formatter != null) {
          return formatter.call(e);
        } else {
          return DynamicText.fromString(formatNumber(e));
        }
      }));
    }
    return labels;
  }

  List<DynamicText> obtainLabel2(int startIndex, int endIndex) {
    List<DynamicText> rl = [];
    List<dynamic> dl = scale.getRangeLabel(startIndex, endIndex);
    for (var data in dl) {
      rl.add(formatData(data));
    }
    return rl;
  }

  AxisTheme getAxisTheme() {
    if (axis.isCategoryAxis) {
      return context.option.theme.categoryAxisTheme;
    }
    if (axis.isTimeAxis) {
      return context.option.theme.timeAxisTheme;
    }
    if (axis.isLogAxis) {
      return context.option.theme.logAxisTheme;
    }
    return context.option.theme.valueAxisTheme;
  }

  bool matchType(dynamic data) {
    if (data is String && scale.isCategory) {
      return true;
    }
    if (data is DateTime && scale.isTime) {
      return true;
    }
    return data is num;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  DynamicText formatData(dynamic data) {
    if (data is DynamicText) {
      return data;
    }
    if (data is String) {
      return DynamicText(data);
    }
    var formatter = axis.axisLabel.formatter;
    if (data is DateTime) {
      if (formatter != null) {
        return formatter.call(data);
      } else {
        return defaultTimeFormat(axis.timeType, data).toText();
      }
    }
    if (data is num) {
      if (formatter != null) {
        return formatter.call(data);
      } else {
        return DynamicText.fromString(formatNumber(data));
      }
    }
    throw ChartError("暂不支持 $runtimeType 进行格式化");
  }

  ///将指定的参数转换为标度尺
  static BaseScale toScale(BaseAxis axis, List<num> range, List<dynamic> dataSet, int? splitCount,
      [double scaleFactor = 1]) {
    if (axis.isCategoryAxis) {
      List<String> sl = List.from(axis.categoryList);
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
      if (axis.inverse) {
        return CategoryScale(List.from(sl.reversed), range, axis.categoryCenter);
      }
      return CategoryScale(sl, range, axis.categoryCenter);
    }
    List<dynamic> ds = [...dataSet];
    if (axis.min != null) {
      if (axis.min != 0 || axis.start0) {
        ds.add(axis.min);
      }
    }
    if (axis.max != null) {
      ds.add(axis.max);
    }
    if (axis.timeRange != null) {
      ds.add(axis.timeRange!.start);
      ds.add(axis.timeRange!.end);
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

    var type = axis.type;
    if (type == AxisType.time || timeList.length >= 2) {
      if (timeList.length < 2) {
        DateTime st = timeList.isEmpty ? DateTime.now() : timeList.first;
        DateTime end = st.add(_timeDurationMap[axis.timeType]!);
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
      if (axis.inverse) {
        resultList = List.from(resultList.reversed);
      }
      return TimeScale(axis.timeType, resultList, range);
    }
    list.sort();

    if (!axis.start0) {
      list.removeWhere((element) => element == 0);
    }

    if (list.isEmpty) {
      list.addAll([axis.start0 ? 0 : 1, 100]);
    } else if (list.length == 1) {
      if (list.first < 0) {
        list.add(axis.start0 ? 0 : list.first - 100);
      } else {
        list.add(axis.start0 ? 0 : list.first + 100);
      }
    }

    List<num> v = extremes<num>(list, (p) => p);
    if (axis.type == AxisType.log) {
      num base = log(axis.logBase);
      List<num> logV = [log(v[0]) / base, log(v[1]) / base];
      v = logV;
    }
    if (scaleFactor < 1) {
      scaleFactor = 1;
    }
    int spn = axis.splitNumber;
    if (spn < 2) {
      spn = 2;
    }
    spn = (spn * scaleFactor).round();
    if (splitCount != null) {
      spn = splitCount;
    }

    NiceScale step = NiceScale.nice(
      v[0],
      v[1],
      spn,
      minInterval: axis.minInterval,
      maxInterval: axis.maxInterval,
      interval: axis.interval,
      start0: axis.start0,
      forceSplitNumber: splitCount != null,
    );

    List<num> resultList = [step.start, step.end];
    if (axis.inverse) {
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
