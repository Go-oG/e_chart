import 'package:e_chart/e_chart.dart';

///将给定的domain映射到range
abstract class BaseScale<D, R extends num> {
  ///表示域的范围(数据)
  late final List<D> domain;

  ///映射域的值(比如坐标等)
  late final List<R> range;

  BaseScale(List<D> domain, List<R> range) {
    if (range.length < 2) {
      throw ChartError('Range 必须大于等于2');
    }
    this.domain = List.from(domain);
    this.range = List.from(range);
  }

  BaseScale<D, R> copyWithRange(List<R> range);

  ///将给定的数据映射到range
  ///返回值可能为一个，也可能是一个范围
  ///当为范围时至少会返回两个
  List<R> toRange(D data);

  List<double> toRangeRatio(D data);

  R convertRatio(double ratio);

  D toData(covariant num range);

  ///返回Tick的个数
  int get tickCount;

  List<D> get labels;

  List<D> getRangeLabel(int startIndex, int endIndex);

  ///Tick之间的距离间距
  double get tickInterval {
    num v = (range[1] - range[0]).abs();
    int c = tickCount;
    if (c <= 1) {
      return v.toDouble();
    }
    c = c - 1;
    return v / c;
  }

  bool get isCategory => false;

  bool get isTime => false;

  bool get isLog => false;

  bool get isNum {
    return !isCategory && !isTime;
  }

  @override
  String toString() {
    return "domain:$domain range:$range";
  }
}
