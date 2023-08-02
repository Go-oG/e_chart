import 'package:e_chart/e_chart.dart';

class LinearScale extends BaseScale<num, num> {
  final num step;

  ///表示域的范围
  LinearScale(
    super.domain,
    super.range, {
    required this.step,
  }) {
    if (domain.length < 2) {
      throw ChartError('LinearScale Domain必须大于等于2');
    }
  }

  @override
  List<num> toRange(num data) {
    num diff = domain.last - domain.first;
    num diff2 = this.range.last - this.range.first;
    double p = diff2 * (data - domain.first) / diff;
    return [this.range.first + p];
  }

  @override
  List<double> toRangeRatio(num data) {
    num diff = domain.last - domain.first;
    if (diff.abs() == 0) {
      return [0];
    }
    return [(data - domain.first) / diff];
  }

  @override
  num convertRatio(double ratio) {
    num diff2 = this.range.last - this.range.first;
    return ratio * diff2 + this.range.first;
  }

  @override
  num toData(num range) {
    num diff = domain.last - domain.first;
    num diff2 = this.range.last - this.range.first;
    if (diff2 == 0) {
      return domain.first;
    }
    double p = (range - this.range.first) / diff2;
    return domain.first + p * diff;
  }

  @override
  int get tickCount {
    num diff = domain[1] - domain[0];
    diff = diff.abs();
    num v2 = step.abs();
    return 1 + diff ~/ v2;
  }

  @override
  LinearScale copyWithRange(List<num> range) {
    return LinearScale(domain, range, step: step);
  }

  @override
  List<num> get labels {
    int count = tickCount;
    num interval = (domain[1] - domain[0]) / (count - 1);
    List<num> tl = [];
    for (int i = 0; i < count; i++) {
      tl.add(domain[0] + interval * i);
    }
    return tl;
  }

  @override
  List<num> getRangeLabel(int startIndex, int endIndex) {
    int count = tickCount;
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex > count) {
      endIndex = count;
    }

    num interval = (domain[1] - domain[0]) / (count - 1);
    List<num> tl = [];
    for (int i = startIndex; i < endIndex; i++) {
      tl.add(domain[0] + interval * i);
    }
    return tl;
  }
}
