import 'package:chart_xutil/chart_xutil.dart';

import '../../model/chart_error.dart';
import '../../model/dynamic_data.dart';
import '../axis/base_axis.dart';
import 'scale_linear.dart';
import 'scale_base.dart';

class TimeScale extends BaseScale<DateTime, num> {
  final TimeSplitType splitType;
  late final LinearScale _lineScale;

  TimeScale(this.splitType, super.domain, super.range, super.inverse) {
    if (domain.length < 2) {
      throw ChartError('LinearScale Domain必须大于等于2');
    }
    _lineScale = LinearScale([0, _convert(domain.first, domain.last, splitType)], this.range, inverse);
  }

  @override
  num rangeValue(DynamicData domainData) {
    int diff = _convert(domain.first, domainData.data, splitType);
    int diff2 = (_lineScale.domain.last - _lineScale.domain.first).toInt();
    double p = diff / diff2;
    return this.range.first + (this.range.last - this.range.first) * p;
  }

  @override
  DateTime domainValue(covariant num rangeData) {
    num diff = (_lineScale.domain.last - _lineScale.domain.first);
    num diff2 = this.range.last - this.range.first;
    double p = (rangeData - this.range.first) / diff2;
    int v = (p * diff).toInt();
    return _convertValue(domain.first, v, splitType);
  }

  @override
  int get tickCount => (_lineScale.domain.last - _lineScale.domain.first).toInt();

  List<DateTime> get ticks {
    List<DateTime> tl = [];
    for (int i = 0; i <= tickCount; i++) {
      tl.add(_convertValue(domain.first, i, splitType));
    }
    return tl;
  }

  static int _convert(DateTime s, DateTime e, TimeSplitType splitType) {
    if (splitType == TimeSplitType.year) {
      return s.diffYear(e);
    }
    if (splitType == TimeSplitType.month) {
      return s.diffMonth(e);
    }
    if (splitType == TimeSplitType.day) {
      return s.diffDay(e);
    }
    if (splitType == TimeSplitType.hour) {
      return s.diffHour(e);
    }
    if (splitType == TimeSplitType.minute) {
      return s.diffMinute(e);
    }
    return s.diffSec(e);
  }

  static DateTime _convertValue(DateTime start, int v, TimeSplitType splitType) {
    if (splitType == TimeSplitType.year) {
      return DateTime(start.year + v, start.month, start.day);
    }
    if (splitType == TimeSplitType.month) {
      int year = start.year;
      year += v ~/ 12;
      int m = v % 12;
      return DateTime(year, m, 1);
    }
    if (splitType == TimeSplitType.day) {
      return start.add(Duration(days: v));
    }
    if (splitType == TimeSplitType.hour) {
      return start.add(Duration(hours: v));
    }
    if (splitType == TimeSplitType.minute) {
      return start.add(Duration(minutes: v));
    }
    return start.add(Duration(seconds: v));
  }
}
