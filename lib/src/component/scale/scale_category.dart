import '../../model/chart_error.dart';
import 'scale_base.dart';

class CategoryScale extends BaseScale<String, num> {
  CategoryScale(
    super.domain,
    super.range,
  ) {
    if (domain.isEmpty) {
      throw ChartError('Domain至少应该有一个');
    }
  }

  @override
  String toData(num range) {
    num diff = this.range.last - this.range.first;
    num interval = diff / domain.length;
    int diff2 = (range - this.range.first) ~/ interval;
    if (diff2 < 0) {
      diff2 = 0;
    }
    if (diff2 >= domain.length) {
      diff2 = domain.length - 1;
    }
    return domain[diff2];
  }

  @override
  List<num> toRange(String data) {
    num index = domain.indexOf(data);
    if (index == -1) {
      return [double.nan, double.nan];
    }
    num diff = range.last - range.first;
    num interval = diff / domain.length;
    return [range.first + index * interval, range.first + (index + 1) * interval];
  }

  @override
  int get tickCount => domain.length+1;

  @override
  bool get isCategory => true;

  @override
  List<String> get ticks=>domain;

  @override
  CategoryScale copyWithRange(List<num> range) {
    return CategoryScale(domain, range);
  }
}
