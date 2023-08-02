import '../model/data.dart';

extension DateTimeExt on DateTime {
  DynamicData toData() {
    return DynamicData(this);
  }
  int maxDay() {
    int curYear = year;
    int curMonth = month;
    if (curMonth < 12) {
      curMonth += 1;
    } else {
      curMonth = 1;
      curYear += 1;
    }
    return DateTime(curYear, curMonth, 0).day;
  }

  bool isAfterDay(DateTime time) {
    if (year < time.year) {
      return false;
    }
    if (year > time.year) {
      return true;
    }
    if (month < time.month) {
      return false;
    }
    if (month > time.month) {
      return true;
    }
    return day > time.day;
  }

  bool isBeforeDay(DateTime time) {
    if (year > time.year) {
      return false;
    }
    if (year < time.year) {
      return true;
    }

    if (month > time.month) {
      return false;
    }
    if (month < time.month) {
      return true;
    }

    return day < time.day;
  }

  bool isSameDay(DateTime time) {
    return year == time.year && month == time.month && day == time.day;
  }

  DateTime monthFirst() {
    return DateTime(year, month, 1, 0, 0, 0);
  }

  DateTime monthLast() {
    return DateTime(year, month, maxDay(), 0, 0, 0);
  }

  DateTime first() {
    return DateTime(year, month, day, 0, 0, 0);
  }

  DateTime last() {
    return DateTime(year, month, day, 23, 59, 59);
  }

  int diffYear(DateTime d) {
    return (d.year - year).abs();
  }

  int diffMonth(DateTime d) {
    DateTime start = this;
    DateTime end = d;
    if (start.millisecondsSinceEpoch > end.millisecondsSinceEpoch) {
      var b = end;
      end = start;
      start = b;
    }
    int yearCount = end.year - start.year;
    int monthCount = end.month - start.month;
    return monthCount + yearCount * 12;
  }

  int diffDay(DateTime d) {
    return computeDayDiff(this, d);
  }

  int diffHour(DateTime d) {
    return d.duration(this).inHours;
  }

  int diffMinute(DateTime d) {
    return d.duration(this).inMinutes;
  }

  int diffSec(DateTime d) {
    return d.duration(this).inSeconds;
  }

  Duration duration(DateTime d) {
    if (millisecondsSinceEpoch > d.millisecondsSinceEpoch) {
      return difference(d);
    }
    return d.difference(this);
  }
}

// 计算两个日期之间相差的天数
int computeDayDiff(DateTime start, DateTime end) {
  return start.duration(end).inDays;
}

// 根据两个日期点 返回两个日期点之间的日期
List<DateTime> buildDateRange(DateTime start, DateTime end, bool include) {
  DateTime firstDate = DateTime(start.year, start.month, start.day, 0, 0, 0);

  int dayDiff = computeDayDiff(start, end);

  List<DateTime> array = [];
  if (include) {
    array.add(firstDate);
  }
  for (int i = 1; i < dayDiff; i += 1) {
    DateTime tempDate = firstDate.add(Duration(days: i));
    array.add(tempDate);
  }
  if (include) {
    array.add(DateTime(end.year, end.month, end.day, 0, 0, 0));
  }
  return array;
}
