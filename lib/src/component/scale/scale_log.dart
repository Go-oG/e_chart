import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';

class LogScale extends LinearScale {
  final num base;

  LogScale(
    super.domain,
    super.range, {
    this.base = 10,
    required super.step,
  }){
    if (base == 0) {
      throw ChartError('Base 必须不为0');
    }
  }

  @override
  LogScale copyWithRange(List<num> range) {
    return LogScale(domain, range, base: base, step: step);
  }

  @override
  num toData(covariant num range) {
    num lg = super.toData(range);
    return m.pow(base, lg);
  }

  @override
  List<num> toRange(num data) {
    return super.toRange(convert(data));
  }

  num convert(num n) {
    return m.log(n) / m.log(base);
  }
}
