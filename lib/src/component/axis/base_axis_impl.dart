import 'dart:math';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L extends AxisAttrs, R extends AxisLayoutResult> extends ChartNotifier<Command> {
  final int axisIndex;
  final Context context;
  final T axis;
  late final AxisTitleNode titleNode;
  late L attrs;
  late BaseScale scale;
  late R layoutResult;

  bool expanded = true;

  BaseAxisImpl(this.context, this.axis, {this.axisIndex = 0}) : super(Command.none) {
    titleNode = AxisTitleNode(axis.name);
  }

  void doMeasure(double parentWidth, double parentHeight) {}

  void doLayout(L attrs, List<DynamicData> dataSet) {
    this.attrs = attrs;
    scale = onBuildScale(attrs, dataSet);
    titleNode.config = onLayoutAxisName();
    layoutResult = onLayout(attrs, scale, dataSet);
  }

  R onLayout(L attrs, BaseScale scale, List<DynamicData> dataSet);

  BaseScale onBuildScale(L attrs, List<DynamicData> dataSet);

  TextDrawConfig onLayoutAxisName();

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

  void draw(Canvas canvas, Paint paint, Rect coord) {
    var axisLine = axis.axisStyle;
    if (!axisLine.show) {
      return;
    }
    onDrawAxisSplitArea(canvas, paint, coord);
    onDrawAxisSplitLine(canvas, paint, coord);
    onDrawAxisTick(canvas, paint);
    onDrawAxisLabel(canvas, paint);
    onDrawAxisLine(canvas, paint);
    onDrawAxisName(canvas, paint);
  }

  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {}

  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {}

  void onDrawAxisName(Canvas canvas, Paint paint) {
    if (titleNode.label == null || titleNode.label!.isEmpty) {
      return;
    }
    axis.nameStyle.draw(canvas, paint, titleNode.label!, titleNode.config);
  }

  void onDrawAxisLine(Canvas canvas, Paint paint) {}

  void onDrawAxisTick(Canvas canvas, Paint paint) {}

  void onDrawAxisLabel(Canvas canvas, Paint paint) {}

  List<DynamicText> obtainLabel() {
    if (scale is CategoryScale) {
      return List.from(scale.labels.map((e) => DynamicText(e)));
    }
    var formatter = axis.axisStyle.axisLabel.formatter;
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

  AxisTheme getAxisTheme() {
    if (axis.isCategoryAxis) {
      return context.config.theme.categoryAxisTheme;
    }
    if (axis.isTimeAxis) {
      return context.config.theme.timeAxisTheme;
    }
    if (axis.isLogAxis) {
      return context.config.theme.logAxisTheme;
    }
    return context.config.theme.valueAxisTheme;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  ///将指定的参数转换为标度尺
  static BaseScale toScale(BaseAxis axis, List<num> range, List<DynamicData> dataSet) {
    if (axis.isCategoryAxis) {
      List<String> sl = List.from(axis.categoryList);
      if (axis.categoryList.isEmpty) {
        Set<String> dSet = {};
        for (var data in dataSet) {
          if (data.isString && !dSet.contains(data.data as String)) {
            sl.add(data.data);
            dSet.add(data.data);
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
    List<DynamicData> ds = [...dataSet];
    ds.add(DynamicData(axis.min));
    if (axis.max != null) {
      ds.add(DynamicData(axis.max));
    }

    if (axis.timeRange != null) {
      ds.add(DynamicData(axis.timeRange!.start));
      ds.add(DynamicData(axis.timeRange!.end));
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

    if (list.length < 2) {
      if (list.length == 1) {
        list.add(list.first + 100);
      } else {
        list.addAll([0, 100]);
      }
    }

    List<num> v = extremes<num>(list, (p) => p);
    if (axis.type == AxisType.log) {
      num base = log(axis.logBase);
      List<num> logV = [log(v[0]) / base, log(v[1]) / base];
      v = logV;
    }
    NiceScale step = NiceScale.nice(
      v[0],
      v[1],
      axis.splitNumber,
      minInterval: axis.minInterval,
      maxInterval: axis.maxInterval,
      interval: axis.interval,
      start0: axis.start0,
      type: axis.niceType,
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
