import 'dart:math' as math;

import 'package:chart_xutil/chart_xutil.dart';

enum NiceType { n1, n2 }

class NiceScale {
  final num start;
  final num end;
  final int tickCount;
  final num step;

  NiceScale(this.start, this.end, this.step, this.tickCount);

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

  static NiceScale nice(
    num min,
    num max,
    int splitNumber, {
    num minInterval = 0,
    num? maxInterval,
    num? interval,
    bool forceSplitNumber = false,
    bool start0 = false,
    NiceType type = NiceType.n1,
  }) {
    if (interval != null) {
      int count = (max - min) ~/ interval;
      if ((max - min) % interval != 0) {
        count += 1;
      }
      return NiceScale(min, max, (max - min) / count, count);
    }

    if (type == NiceType.n1) {
      return _niceAxis(
        min,
        max,
        splitNumber,
        minInterval: minInterval,
        maxInterval: maxInterval,
        interval: null,
        forceSplitNumber: forceSplitNumber,
        start0: start0,
      );
    }

    //第二种算法
    int oldCount = splitNumber;
    num rawInterval = (max - min) / splitNumber;
    if (rawInterval < minInterval) {
      rawInterval = minInterval;
    }
    if (maxInterval != null) {
      if (rawInterval > maxInterval) {
        rawInterval = maxInterval;
      }
    }
    splitNumber = (max - min) ~/ rawInterval;
    if ((max - min) % rawInterval != 0) {
      splitNumber += 1;
    }

    int onlyInside = -1;

    _NiceNumber number2 = _NiceNumber.nice(min, max, splitNumber, onlyInside: onlyInside);
    NiceScale rangeValue = NiceScale(number2.minValue, number2.maxValue, number2.step, number2.tickCount);
    if (forceSplitNumber) {
      return rangeValue.copy(tickCount: oldCount);
    }
    return rangeValue;
  }

  ///依据给定的数据和参数生成美观的数值范围
  static NiceScale _niceAxis(
    num min,
    num max,
    int splitNumber, {
    num minInterval = 0,
    num? maxInterval,
    num? interval,
    bool forceSplitNumber = false,
    bool start0 = false,
  }) {
    int oldCount = splitNumber;
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
    splitNumber = (max - min) ~/ rawInterval;
    if ((max - min) % rawInterval != 0) {
      splitNumber += 1;
    }
    NiceScale rangeValue = _standRange(min, max, tickCount: splitNumber, startWith0: start0);
    if (forceSplitNumber) {
      return rangeValue.copy(tickCount: oldCount);
    }
    return rangeValue;
  }

  static NiceScale _standRange(num min, num max, {int tickCount = 5, bool startWith0 = false}) {
    // 数据全部分布在x轴同一侧，而且需要从零开始计算
    if (startWith0 && min * max >= 0) {
      min = min > 0 ? 0 : min;
      max = max < 0 ? 0 : max;
    }
    if (max == min) {
      num t = min.abs();
      num mag = t == 0 ? 1 : math.pow(10, log10(t).floor());
      List<num> list = _adjustAxisRange(min, max, mag);
      int count = list[2].toInt();
      return NiceScale(list[0], list[1], (list[1] - list[0]) / count, count);
    }

    // 刻度区间长度，和长度数量级
    num tickInterval, mag;
    num rawTickInterval = (max - min) / tickCount;
    // 计算数量级
    mag = math.pow(10, (log10(rawTickInterval)).floor());
    if (mag == rawTickInterval) {
      mag = rawTickInterval;
    } else {
      mag = mag * 10;
    }
    tickInterval = rawTickInterval / mag;

    //选取规范步长
    num stepLen = _mapStandInterval(tickInterval);
    tickInterval = stepLen * mag;
    var res = _adjustAxisRange(min, max, tickInterval);
    if (res[2] > tickCount) {
      //如果最后计算得出的刻度数大于计算值，步长扩大一级
      tickInterval = _mapStandInterval(stepLen + 0.1) * mag;
      res = _adjustAxisRange(min, max, tickInterval);
    }
    int count = res[2].toInt();
    return NiceScale(res[0], res[1], (res[1] - res[0]) / count, count);
  }

  ///映射标准步长值
  ///[originStep]原始步长值
  static double _mapStandInterval(num originStep) {
    if (originStep <= 0.1) {
      return 0.1;
    }
    if (originStep <= 0.2) {
      return 0.2;
    }
    if (originStep <= 0.25) {
      return 0.25;
    }
    if (originStep <= 0.5) {
      return 0.5;
    }
    if (originStep < 1) {
      return 1;
    }
    return _mapStandInterval(originStep / 10) * 10;
  }

  ///调整坐标轴的范围和步长值
  static List<num> _adjustAxisRange(num min, num max, num tickInterval) {
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
}

class _NiceNumber {
  final num minValue;
  final num maxValue;
  final num step;
  final int tickCount;
  final double score; //得分

  _NiceNumber(this.minValue, this.maxValue, this.step, this.tickCount, this.score);

  static num _coverage(num minData, num maxData, num minLabel, num maxLabel) {
    num p1 = math.pow(maxData - maxLabel, 2);
    num p2 = math.pow(minData - minLabel, 2);
    num p3 = math.pow(maxData - minData, 2);
    return 1 - 0.5 * (p1 + p2) / (0.1 * p3);
  }

  static num _coverageMax(num minData, num maxData, num span) {
    var dataRange = maxData - minData;
    if (span > dataRange) {
      return 1 - math.pow(0.5 * (span - dataRange), 2) / math.pow(0.1 * dataRange, 2);
    }
    return 1;
  }

  static num _density(num k, num tickCount, num minData, num maxData, num minLabel, num maxLabel) {
    var r = (k - 1) / (maxLabel - minLabel);
    var rt = (tickCount - 1) / (math.max(maxLabel, maxData) - math.min(minLabel, minData));
    return 2 - math.max(r / rt, rt / r);
  }

  static num _densityMax(num k, num tickCount) {
    if (k >= tickCount) {
      return 2 - (k - 1.0) / (tickCount - 1.0);
    }
    return 1;
  }

  static num _simplicity(num niceNumber, List<num> niceNumbers, num j, num minLabel, num maxLabel, num stepLength) {
    var eps = 1e-10;
    int n = niceNumbers.length;
    int i = niceNumbers.indexOf(niceNumber) + 1;
    var v = 0;
    bool b1 = (minLabel % stepLength) < eps;
    bool b2 = (stepLength - minLabel) % stepLength < eps;

    if (b1 || (b2 && (minLabel <= 0) && (maxLabel >= 0))) {
      v = 1;
    } else {
      v = 0;
    }
    return (n - i) / (n - 1.0) + v - j;
  }

  static num _simplicityMax(num niceNumber, List<num> niceNumbers, num j) {
    var n = niceNumbers.length;
    var i = niceNumbers.indexOf(niceNumber) + 1;
    var v = 1;
    return (n - i) / (n - 1.0) + v - j;
  }

  static num _legibility(num minLabel, num maxLabel, num stepLength) {
    return 1;
  }

  //评分计算函数
  static double _score(List<num> weights, num simplicity, num coverage, num density, num legibility) {
    return (weights[0] * simplicity + weights[1] * coverage + weights[2] * density + weights[3] * legibility).toDouble();
  }

  ///[weights] 控制四个重要标准权重列表：简单性、覆盖率、密度和易读性
  ///[onlyInside]
  ///控制第一个和最后一个标签是否包括该数据范围。
  /// 0 : 无所谓; >0 : 标签范围必须包括数据范围;<0 : 数据范围必须大于标签范围
  static _NiceNumber nice(
    num minData,
    num maxData,
    int tickCount, {
    int onlyInside = -1,
    List<num> niceNumbers = const [1, 5, 2, 2.5, 4, 3],
    List<num> weights = const [0.2, 0.25, 0.5, 0.05],
  }) {
    if (minData >= maxData || tickCount < 1) {
      return _NiceNumber(minData, maxData, maxData - minData, 2, 0);
    }
    double bestScore = -1.0;
    _NiceNumber result = _NiceNumber(0, 0, 0, 0, 0);
    num j = 1;
    while (j < double.infinity) {
      for (var q in niceNumbers) {
        var sm = _simplicityMax(q, niceNumbers, j);
        if (_score(weights, sm, 1, 1, 1) < bestScore) {
          j = double.infinity;
          break;
        }
        var k = 2;
        while (k < double.infinity) {
          var dm = _densityMax(k, tickCount);
          if (_score(weights, sm, 1, dm, 1) < bestScore) {
            break;
          }

          var delta = (maxData - minData) / (k + 1) / j / q;
          var z = (log10(delta)).ceil();
          while (z < double.infinity) {
            var step = j * q * math.pow(10, z);
            var cm = _coverageMax(minData, maxData, step * (k - 1));

            if (_score(weights, sm, cm, dm, 1) < bestScore) {
              break;
            }
            var minStart = (maxData / step).floor() * j - (k - 1) * j;
            var maxStart = (minData / step).ceil() * j;
            if (minStart > maxStart) {
              z += 1;
              break;
            }

            for (var start = minStart; start < maxStart + 1; start += 1) {
              var minLength = start * (step / j);
              var maxLength = minLength + step * (k - 1.0);
              var stepLength = step;
              var s = _simplicity(q, niceNumbers, j, minLength, maxLength, stepLength);
              var c = _coverage(minData, maxData, minLength, maxLength);
              var d = _density(k, tickCount, minData, maxData, minLength, maxLength);
              var l = _legibility(minLength, maxLength, stepLength);
              var score = _score(weights, s, c, d, l);

              bool b1 = score > bestScore;
              bool b2 = onlyInside <= 0 || ((minLength >= minData) && (maxLength <= maxData));
              bool b3 = onlyInside >= 0 || ((minLength <= minData) && (maxLength >= maxData));
              if (b1 && b2 && b3) {
                bestScore = score;
                result = _NiceNumber(minLength, maxLength, stepLength, k, score);
              }
            }
            z += 1;
          }
          k += 1;
        }
      }
      j += 1;
    }
    return result;
  }
}
