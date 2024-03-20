import 'dart:math' as math;
import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

Random _random = Random();

T max2<T extends num>(Iterable<T> list) {
  return maxBy<T>(list, (p0) => p0);
}

T maxBy<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw FlutterError('列表为空');
  }
  num v = convert.call(list.first);
  T result = list.first;
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) > 0) {
      v = tv;
      result = v2;
    }
  }
  return result!;
}

num maxBy2<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw FlutterError('列表为空');
  }
  num v = convert.call(list.first);
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) > 0) {
      v = tv;
    }
  }
  return v;
}

T min2<T extends num>(Iterable<T> list) {
  return minBy<T>(list, (p0) => p0);
}

T minBy<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw ChartError('List Is Empty');
  }
  num v = convert.call(list.first);
  T result = list.first;
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) < 0) {
      v = tv;
      result = v2;
    }
  }
  return result;
}

num minBy2<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw ChartError('List Is Empty');
  }
  num v = convert.call(list.first);
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) < 0) {
      v = tv;
    }
  }
  return v;
}

List<num> extremes<T>(Iterable<T> list, num Function(T) call) {
  if (list.isEmpty) {
    return [0, 0];
  }
  T first = list.first;
  num minValue = call(first);
  num maxValue = call(first);

  for (var ele in list) {
    num v = call(ele);
    minValue = math.min(minValue, v);
    maxValue = math.max(maxValue, v);
  }
  return [minValue, maxValue];
}

num sum(Iterable<num> list) {
  return sumBy<num>(list, (p0) => p0);
}

num sumBy<T>(Iterable<T> list, num Function(T) call) {
  return reduce<T>(list, (p0, p1) => p0 + call.call(p1));
}

num ave(Iterable<num> list) {
  return aveBy<num>(list, (p0) => p0);
}

num aveBy<T>(Iterable<T> list, num Function(T) call) {
  if (list.isEmpty) {
    return 0;
  }
  return sumBy<T>(list, call) / list.length;
}

num reduce<T>(Iterable<T> list, num Function(num, T) call, [num initValue = 0]) {
  return reduce2<T, num>(list, call, initValue);
}

///中位数
num medium(Iterable<num> list) {
  return mediumBy<num>(list, (p0) => p0);
}

num mediumBy<T>(Iterable<T> list, num Function(T) call) {
  List<num> nl = [];
  for (var element in list) {
    nl.add(call(element));
  }
  nl.sort();
  int index = nl.length ~/ 2;
  if (nl.length % 2 == 0) {
    return (nl[index] + nl[index + 1]) / 2;
  } else {
    return nl[index];
  }
}

num log10(num v) {
  return math.log(v) / math.ln10;
}

num hypot(List<num> list) {
  double a = 0;
  for (var c in list) {
    a += c * c;
  }
  return math.sqrt(a);
}

///求三角形面积
num triangleArea(Offset p1, Offset p2, Offset p3) {
  return 0.5 * ((p1.dx * p2.dy - p2.dx * p1.dy) + (p2.dx * p3.dy - p3.dx * p2.dy) + (p3.dx * p1.dy - p1.dx * p3.dy));
}

num clamp(num lower, num upper) {
  var p = _random.nextDouble();
  var diff = (upper - lower);
  return lower + diff * p;
}

List<int> range(int start, int end, [int step = 1]) {
  int index = -1;
  int length = max(((end - start) / step).ceil(), 0);
  List<int> rl = List.filled(length, 0);
  while ((length--) != 0) {
    rl[++index] = start;
    start += step;
  }
  return rl;
}
