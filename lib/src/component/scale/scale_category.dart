import '../../model/chart_error.dart';
import 'scale_base.dart';

class CategoryScale extends BaseScale<String, num> {
  bool categoryCenter;

  CategoryScale(super.domain, super.range, this.categoryCenter) {
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
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    if (c <= 0) {
      c = 1;
    }
    num interval = diff / c;
    return [range.first + index * interval, range.first + (index + 1) * interval];
  }

  @override
  num convertRatio(double ratio) {
    num diff = range.last - range.first;
    return range.first + ratio * diff;
  }

  @override
  List<double> toRangeRatio(String data) {
    num index = domain.indexOf(data);
    if (index == -1) {
      return [0, 0];
    }
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    if (c <= 0) {
      c = 1;
    }

    return [index / c, (index + 1) / c];
  }

  @override
  double get tickInterval {
    var dis = (range[1] - range[0]).abs();
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    return dis / c;
  }

  @override
  int get tickCount => categoryCenter ? domain.length + 1 : domain.length;

  @override
  bool get isCategory => true;

  @override
  List<String> get labels => domain;

  @override
  CategoryScale copyWithRange(List<num> range) {
    return CategoryScale(domain, range, categoryCenter);
  }

  @override
  List<String> getRangeLabel(int startIndex, int endIndex) {
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex > domain.length) {
      endIndex = domain.length;
    }
    List<String> dl = [];
    for (int i = startIndex; i < endIndex; i++) {
      dl.add(domain[i]);
    }
    return dl;
  }
}
