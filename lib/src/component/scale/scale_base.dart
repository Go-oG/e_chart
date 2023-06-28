import 'package:e_chart/e_chart.dart';

import '../../model/dynamic_data.dart';

///将给定的domain映射到range
abstract class BaseScale<D, R extends num> {
  ///表示域的范围
  late final List<D> domain;

  ///映射域的值(比如坐标等)
  final List<R> range;

  final bool inverse;

  ///当inverse为true时我们将反转domain
  BaseScale(List<D> domain, this.range, this.inverse) {
    if (inverse) {
      this.domain = List.from(domain.reversed);
    } else {
      this.domain = domain;
    }
  }

  num rangeValue(DynamicData domainData);

  ///特殊情况下(比如category)时，需要返回一个范围
  List<num> rangeValue2(DynamicData domainData) {
    throw ChartError("暂未实现该方法");
  }

  D domainValue(covariant num rangeData);

  int get tickCount;

  num get viewInterval {
    num v = (range[1] - range[0]).abs();
    int c = tickCount;
    if (c <= 1) {
      return v;
    }
    c = c - 1;
    return v / c;
  }

  bool get isCategory=>false;
}
