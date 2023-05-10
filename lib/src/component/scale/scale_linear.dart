
import '../../model/dynamic_data.dart';
import 'scale_base.dart';

class LinearScale extends BaseScale<num, num> {
  late final int _tickCount;

  ///表示域的范围
  LinearScale(super.domain, super.range, super.inverse, [int tickCount = 0]) {
    _tickCount = tickCount;
  }

  @override
  num rangeValue(DynamicData domainData) {
    num diff = domain.last - domain.first;
    num diff2 = range.last - range.first;
    double p = diff2 * (domainData.data - domain.first) / diff;
    return range.first + p;
  }

  @override
  num domainValue(covariant num rangeData) {
    num diff = domain.last - domain.first;
    num diff2 = range.last - range.first;
    double p = (rangeData - range.first) / diff2;
    return domain.first + p * diff;
  }

  @override
  int get tickCount => _tickCount;
}
