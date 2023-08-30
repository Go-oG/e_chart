import 'package:e_chart/e_chart.dart';

///存储数据处理结果
class AxisGroup<T extends StackItemData, P extends StackGroupData<T>> {
  ///存储不同坐标轴的数据
  final Map<AxisIndex, List<GroupNode<T, P>>> groupMap;
  final Map<AxisIndex, DataStore<SingleNode<T, P>>> storeMap = {};

  AxisGroup(this.groupMap);

  void mergeData(Direction direction) {
    groupMap.forEach((key, value) {
      List<SingleNode<T, P>> nodeList = [];
      for (var ele in value) {
        ele.mergeData();
        for (var col in ele.nodeList) {
          nodeList.addAll(col.nodeList);
        }
      }
      DataStore<SingleNode<T, P>> store = DataStore(nodeList, (data) {
        if (direction == Direction.vertical) {
          return data.originData?.x;
        }
        return data.originData?.y;
      });
      storeMap[key] = store;
    });
  }

  int getColumnCount(AxisIndex index) {
    List<GroupNode>? group = groupMap[index];
    if (group == null || group.isEmpty) {
      return 0;
    }
    return group.first.nodeList.length;
  }
}

///用于解决大数据量下数据的获取
class DataStore<T> {
  static const int _soreSize = 500;
  final dynamic Function(T data) accessor;

  DataStore(List<T?> list, this.accessor) {
    _parse(list);
  }

  Map<String, List<T>> _strMap = {};
  Map<int, List<T>> _timeMap = {};
  Map<int, List<T>> _numMap = {};

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
    }
    if (numList.isEmpty) {
      _numBase = 1;
      return;
    }
    if (numList.length == 1) {
      _numBase = 1;
    } else {
      List<num> ext = extremes(numList, (p0) {
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
