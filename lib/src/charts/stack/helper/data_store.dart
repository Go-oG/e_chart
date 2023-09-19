
import '../../../model/chart_error.dart';
import '../../../utils/math_util.dart';

///用于优化解决大数据量下数据的获取
///支持按时间维度、字符串维度、数字维度来进行数据的管理
class DataStore<T> {
  static const int _soreSize = 500;
  final dynamic Function(T data) accessor;

  DataStore(List<T?> list, this.accessor) {
    _parse(list);
  }

  Map<String, List<T>> _strMap = {};
  Map<int, List<T>> _timeMap = {};
  Map<int, List<T>> _numMap = {};

  ///存储数字基数
  late final double _numBase;

  void _parse(List<T?> list) {
    _strMap = {};
    _timeMap = {};
    _numMap = {};
    List<T> numList = [];
    for (var node in list) {
      if (node == null) {
        continue;
      }
      dynamic key = accessor.call(node);
      if (key == null) {
        continue;
      }
      if (key is String) {
        List<T> strList = _strMap[key] ?? [];
        _strMap[key] = strList;
        strList.add(node);
        continue;
      }
      if (key is DateTime) {
        List<T> timeList = _timeMap[key.millisecondsSinceEpoch] ?? [];
        _timeMap[key.millisecondsSinceEpoch] = timeList;
        timeList.add(node);
        continue;
      }
      if (key is num) {
        numList.add(node);
      }
      throw ChartError("只支持num、String、DateTime");
    }

    if (numList.isEmpty) {
      _numBase = 1;
      return;
    }

    if (numList.length == 1) {
      _numBase = 1;
    } else {
      var ext = extremes(numList, (p0) {
        return accessor.call(p0);
      });
      num diff = (ext.last - ext.first).abs();
      if (diff == 0) {
        diff = 1;
      }
      _numBase = diff / _soreSize;
    }
    for (var node in numList) {
      num key = accessor.call(node) as num;
      int page = (key / _numBase).floor();
      List<T> nl = _numMap[page] ?? [];
      _numMap[page] = nl;
      nl.add(node);
    }
  }

  List<List<T>> getByStr(List<String> list) {
    List<List<T>> sl = [];
    for (var str in list) {
      List<T>? tl = _strMap[str];
      if (tl != null) {
        sl.add(tl);
      }
    }
    return sl;
  }

  List<List<T>> getByTime(List<DateTime> list) {
    List<List<T>> rl = [];
    for (var time in list) {
      List<T>? tl = _timeMap[time.millisecondsSinceEpoch];
      if (tl != null) {
        rl.add(tl);
      }
    }
    return rl;
  }

  List<List<T>> getByNum(num start, num end) {
    if (start > end) {
      num t = start;
      start = end;
      end = t;
    }
    int si = (start / _numBase).floor();
    int ei = (end / _numBase).floor();
    List<List<T>> rl = [];
    for (int i = si; i <= ei; i++) {
      List<T>? tl = _numMap[i];
      if (tl != null) {
        rl.add(tl);
      }
      if (si == ei) {
        break;
      }
    }
    return rl;
  }
}
