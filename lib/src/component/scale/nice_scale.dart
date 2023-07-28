import 'dart:math' as math;

import 'package:chart_xutil/chart_xutil.dart';

///将给定的数据范围格式化成美观的数据
///如果[interval]不为空且大于0，那么将强制按照指定的interval进行分割
///如果[keepSplitCount]为true 返回结果的分割数分将一定等于splitNumber,适用于多个坐标轴需要标签对齐时使用
///[start0] 如果为true 则将起点设置为0(if min >0)
NiceScale _nice(
  num min,
  num max,
  int splitNumber, {
  num minInterval = 0,
  num? maxInterval,
  num? interval,
  bool keepSplitCount = false,
  bool start0 = false,
}) {
  if (min > max) {
    num t = min;
    min = max;
    max = t;
  }

  if (splitNumber < 2) {
    splitNumber = 2;
  }

  if (interval != null && interval > 0) {
    int count = (max - min) ~/ interval;
    if ((max - min) % interval != 0) {
      count += 1;
    }
    return NiceScale(min, interval * count, interval, count);
  }

  return _niceAxis(min, max, splitNumber,
      minInterval: minInterval, maxInterval: maxInterval, keepSplitCount: keepSplitCount, start0: start0);
}

///依据给定的数据和参数生成美观的数值范围
NiceScale _niceAxis(num min, num max, int splitNumber,
    {num minInterval = 0, num? maxInterval, bool keepSplitCount = false, bool start0 = false}) {
  final int oldCount = splitNumber;

  ///计算原始分隔间隔
  num rawInterval = (max - min) / splitNumber;
  if (rawInterval < minInterval) {
    rawInterval = minInterval;
  }
  if (maxInterval != null) {
    rawInterval = math.max(maxInterval, rawInterval);
  }
  if (rawInterval == 0) {
    rawInterval = 1;
  }

  ///计算新的分割数
  int splitCount = (max - min) ~/ rawInterval;
  if ((max - min) % rawInterval != 0) {
    splitCount += 1;
  }

  return _standRange(min, max, splitCount, oldCount, start0, keepSplitCount);
}

NiceScale _standRange(num min, num max, int splitCount, int oldCount, bool startWith0, bool keepCount) {
  /// 数据全部分布在轴同一侧，而且需要从零开始计算
  if (startWith0 && min * max >= 0) {
    min = min > 0 ? 0 : min;
    max = max < 0 ? 0 : max;
  }

  if (max == min) {
    num t = min.abs();

    ///计算数量级
    num mag = t == 0 ? 1 : math.pow(10, log10(t).floor());
    List<num> list = _adjustAxisRange(min, max, mag);
    int count = list[2].toInt();
    double step = (list[1] - list[0]) / count;
    if (keepCount && count != oldCount) {
      return NiceScale(list[0], list[0] + step * oldCount, step, oldCount + 1);
    }
    return NiceScale(list[0], list[1], step, count + 1);
  }

  int c = keepCount ? oldCount : splitCount;

  ///刻度区间长度，和长度数量级
  num tickInterval, mag;
  num rawTickInterval = (max - min) / c;

  /// 计算数量级
  mag = math.pow(10, (log10(rawTickInterval)).floor());
  if (mag == rawTickInterval) {
    mag = rawTickInterval;
  } else {
    mag = mag * 10;
  }
  tickInterval = rawTickInterval / mag;

  ///选取规范步长
  num stepLen = _mapStandInterval(tickInterval);
  tickInterval = stepLen * mag;
  var res = _adjustAxisRange(min, max, tickInterval);
  if (res[2] > splitCount) {
    ///如果计算得出的刻度数大于给定值，步长扩大一级
    tickInterval = _mapStandInterval(stepLen + 0.1) * mag;
    res = _adjustAxisRange(min, max, tickInterval);
  }
  int count = res[2].toInt();
  return NiceScale(res[0], res[1], (res[1] - res[0]) / count, count);
}

///映射标准步长值
///[originStep]原始步长值
final List<num> _stand = List.from([0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1], growable: false);

///将给定的值映射到标准间隔
double _mapStandInterval(num originStep) {
  for (int i = 0; i < _stand.length; i++) {
    var d = _stand[i];
    if (originStep <= d) {
      return d.toDouble();
    }
  }

  ///降一个数量级计算
  return _mapStandInterval(originStep / 10) * 10;
}

///调整坐标轴的范围和步长值
List<num> _adjustAxisRange(num min, num max, num tickInterval) {
  num temMin = 0;
  if (min < 0) {
    while (temMin > min) {
      temMin -= tickInterval;
    }
  } else {
    while (temMin + tickInterval < min) {
      temMin += tickInterval;
    }
  }
  min = temMin;
  int tickCount = 1;
  while (tickCount * tickInterval + min < max) {
    tickCount++;
  }
  max = tickCount * tickInterval + min;
  return [min, max, tickCount];
}

///优化坐标轴显示
class NiceScale {
  final num start;
  final num end;
  final int tickCount;
  final num step;

  NiceScale(this.start, this.end, this.step, this.tickCount);

  static NiceScale nice(
    num min,
    num max,
    int splitNumber, {
    num minInterval = 0,
    num? maxInterval,
    num? interval,
    bool forceSplitNumber = false,
    bool start0 = false,
  }) {
    return _nice(min, max, splitNumber,
        minInterval: minInterval, maxInterval: maxInterval, interval: interval, keepSplitCount: forceSplitNumber, start0: start0);
  }

  NiceScale copy({num? start, num? end, int? tickCount, num? step}) {
    return NiceScale(
      start ?? this.start,
      end ?? this.end,
      step ?? this.step,
      tickCount ?? this.tickCount,
    );
  }

  @override
  String toString() {
    return 'start:${start.toStringAsFixed(2)} end:${end.toStringAsFixed(2)} tickCount:${tickCount} sep:${step.toStringAsFixed(2)}';
  }
}
