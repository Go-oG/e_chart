import '../../functions.dart';
import '../../model/index.dart';

///通用的极值信息存储
class ExtremeHelper<T> {
  ///返回X轴和Y轴方向上的数据
  final Fun3<T, String, dynamic> valueFun;

  ///返回当前数据使用的坐标维度索引
  final Fun2<T, List<String>> axisDimFun;

  ExtremeHelper(this.axisDimFun, this.valueFun, Iterable<T> data) {
    _parse(data);
  }

  ///存储坐标轴上的极值数据
  Map<String, ExtremeInfo2> _dimExtreme = {};

  ExtremeInfo2 getExtreme(String dimIndex) {
    var info = _dimExtreme[dimIndex];
    if (info != null) {
      return info;
    }
    info = ExtremeInfo2(dimIndex, [], [], []);
    _dimExtreme[dimIndex] = info;
    return info;
  }

  void _parse(Iterable<T> data) {
    ///将数据根据使用的坐标轴索引进行分割
    Map<String, List<T>> dimMap = _splitDataForDim(data);

    ///最后进行数据合并整理
    _dimExtreme = _collectExtreme(dimMap);
  }

  Map<String, List<T>> _splitDataForDim(Iterable<T> data) {
    Map<String, List<T>> resultMap = {};
    for (var d in data) {
      List<String> dimList = axisDimFun.call(d);
      for (var dim in dimList) {
        List<T> list = resultMap[dim] ?? [];
        resultMap[dim] = list;
        list.add(d);
      }
    }
    return resultMap;
  }

  Map<String, ExtremeInfo2> _collectExtreme(Map<String, List<T>> dataMap) {
    Map<String, NumExtreme> numMap = {};
    Map<String, TimeExtreme> timeMap = {};
    Map<String, List<String>> strMap = {};
    dataMap.forEach((key, value) {
      var dimIndex = key;
      for (var dd in value) {
        var v = valueFun.call(dd, dimIndex);
        if (v == null) {
          continue;
        }
        if (v is Map) {
          throw ChartError('not support map');
        }

        List<dynamic> dl = [];
        if (v is String || v is DateTime || v is num) {
          dl.add(v);
        } else if (v is Iterable) {
          dl.addAll(v);
        } else {
          throw ChartError('not support ${v.runtimeType}');
        }

        for (var data in dl) {
          if (data == null) {
            continue;
          }
          if (data is String) {
            var strList = strMap[dimIndex] ?? [];
            strMap[dimIndex] = strList;
            strList.add(data);
            continue;
          }
          if (data is num) {
            var extreme = numMap[dimIndex] ?? NumExtreme();
            numMap[dimIndex] = extreme;
            if (extreme.minValue == null || (data < extreme.minValue!)) {
              extreme.minValue = data;
            }
            if (extreme.maxValue == null || (data > extreme.maxValue!)) {
              extreme.maxValue = data;
            }
            continue;
          }
          if (data is DateTime) {
            var extreme = timeMap[dimIndex] ?? TimeExtreme();
            timeMap[dimIndex] = extreme;
            if (extreme.minTime == null || (data.isBefore(extreme.minTime!))) {
              extreme.minTime = data;
            }
            if (extreme.maxTime == null || (data.isAfter(extreme.maxTime!))) {
              extreme.maxTime = data;
            }
            continue;
          }
          throw ChartError("不支持的数据类型 ${data.runtimeType}");
        }
      }
    });

    Map<String, ExtremeInfo2> infoMap = {};
    numMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo2(key, [], [], []);
      infoMap[key] = info;
      var v = value.minValue;
      if (v != null && v.isFinite) {
        info.numExtreme.add(v);
      }
      v = value.maxValue;
      if (v != null && v.isFinite) {
        info.numExtreme.add(v);
      }
    });
    timeMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo2(key, [], [], []);
      infoMap[key] = info;
      var v = value.minTime;
      if (v != null) {
        info.timeExtreme.add(v);
      }
      v = value.maxTime;
      if (v != null) {
        info.timeExtreme.add(v);
      }
    });
    strMap.forEach((key, value) {
      var info = infoMap[key] ?? ExtremeInfo2(key, [], [], []);
      infoMap[key] = info;
      info.strExtreme.addAll(value);
    });
    Map<String, ExtremeInfo2> rm = {};
    infoMap.forEach((key, value) {
      value.syncData();
      rm[value.axisIndex] = value;
    });
    return rm;
  }
}
