import 'package:e_chart/e_chart.dart';

class RangeInfo {
  final List<String>? categoryList;
  final List<DateTime>? timeList;
  final Pair<num>? numRange;

  const RangeInfo.category(List<String> list)
      : categoryList = list,
        timeList = null,
        numRange = null;

  const RangeInfo.time(List<DateTime> list)
      : timeList = list,
        categoryList = null,
        numRange = null;

  const RangeInfo.range(Pair<num> pair)
      : timeList = null,
        categoryList = null,
        numRange = pair;

  @override
  String toString() {
    if (categoryList != null) {
      return "$categoryList";
    }
    if (timeList != null) {
      return "$timeList";
    }
    if (numRange != null) {
      return "[${numRange!.start} , ${numRange!.end}]";
    }

    return "暂无数据";
  }
}
