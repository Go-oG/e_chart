import 'package:chart_xutil/chart_xutil.dart';

import '../../model/chart_error.dart';
import '../axis/base_axis.dart';
import 'scale_base.dart';

/// 支持年月日 周
class TimeScale extends BaseScale<DateTime, num> {
  final TimeSplitType splitType;

  TimeScale(this.splitType, super.domain, super.range) {
    if (domain.length < 2) {
      throw ChartError('TimeScale Domain必须大于等于2');
    }
  }

  @override
  List<num> toRange(DateTime data) {
    int diff = _convert(domain.first, domain.last, splitType);
    int diff2 = _convert(domain.first, data, splitType);
    double p = diff / diff2;
    return [this.range.first + (this.range.last - this.range.first) * p];
  }

  @override
  DateTime toData(covariant num range) {
    int diff = _convert(domain.first, domain.last, splitType);
    num diff2 = this.range.last - this.range.first;
    double p = (range - this.range.first) / diff2;
    int v = (p * diff).ceil();
    return _convertValue(domain.first, v, splitType);
  }

  @override
  int get tickCount => _convert(domain.first, domain.last, splitType)+1;

  @override
  bool get isTime => true;

  @override
  List<DateTime> get ticks {
    List<DateTime> tl = [];
    int count = tickCount;
    for (int i = 0; i <= count; i++) {
      tl.add(_convertValue(domain.first, i, splitType));
    }
    return tl;
  }

  static int _convert(DateTime s, DateTime e, TimeSplitType splitType) {
    if (splitType == TimeSplitType.week) {
      int day = s.diffDay(e);
      if (day % 7 == 0) {
        return day;
      }
      return day ~/ 7 + 1;
    }

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
    if (splitType == TimeSplitType.week) {
      return start.add(Duration(days: v * 7));
    }
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

  @override
  TimeScale copyWithRange(List<num> range) {
    return TimeScale(splitType, domain, range);
  }
}
