import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_data.dart';

///处理二维坐标系下堆叠数据
///只针对数字类型处理
class DataHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends ChartSeries> {
  final List<P> _dataList;
  final S _series;

  late AxisGroup<T, P> _result;

  DataHelper(this._series, this._dataList) {
    _result = _parse();
  }

  AxisGroup<T, P> get result {
    return _result;
  }

  Map<AxisIndex, List<num>> _extremeMap = {};

  List<num> getExtreme(int axisIndex) {
    if (_extremeMap.isEmpty) {
      return [];
    }
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    AxisIndex index = AxisIndex(axisIndex);
    List<num> dl = _extremeMap[index] ?? [];
    return dl;
  }

  OriginInfo<T, P> _originInfo = OriginInfo({}, {});

  ///解析数据的原始信息
  ///包括子数据-父数据映射关系、
  ///排序索引
  OriginInfo<T, P> _parseOriginInfo(List<P> dataList) {
    Map<P, int> sortMap = {};
    Map<T, P> parentMap = {};
    each(dataList, (p0, p1) {
      if (!sortMap.containsKey(p0)) {
        sortMap[p0] = p1;
      }
      for (var ele in p0.data) {
        parentMap[ele] = p0;
      }
    });
    return OriginInfo(sortMap, parentMap);
  }

  ///将给定的数据按照其使用的X 坐标轴进行分割
  Map<AxisIndex, List<StackGroup<T, P>>> _splitDataByAxis(OriginInfo<T, P> originInfo, List<P> dataList) {
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in dataList) {
      int xIndex = group.xAxisIndex ?? _series.xAxisIndex;
      if (xIndex < 0) {
        xIndex = 0;
      }
      AxisIndex index = AxisIndex(xIndex);
      if (!axisGroupMap.containsKey(index)) {
        axisGroupMap[index] = [];
      }
      axisGroupMap[index]!.add(group);
    }
    Map<AxisIndex, List<StackGroup<T, P>>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = _handleSingleAxis(key, value, originInfo);
    });
    return resultMap;
  }

  List<StackGroup<T, P>> _handleSingleAxis(AxisIndex axisIndex, List<P> list, OriginInfo<T, P> originInfo) {
    int barGroupCount = _computeBarCount(list);
    List<List<T>> itemList = List.generate(barGroupCount, (index) => []);
    for (int i = 0; i < barGroupCount; i++) {
      for (var data in list) {
        if (data.data.length <= i) {
          continue;
        }
        itemList[i].add(data.data[i]);
      }
    }

    List<StackGroup<T, P>> groupList = [];

    ///合并数据
    each(itemList, (group, index) {
      ///<stackId>
      Map<String, List<T>> stackDataMap = {};
      List<T> singleDataList = [];
      each(group, (data, p1) {
        var parent = originInfo.parentMap[data]!;
        if (parent.isStack) {
          List<T> dl = stackDataMap[parent.stackId!] ?? [];
          stackDataMap[parent.stackId!] = dl;
          dl.add(data);
        } else {
          singleDataList.add(data);
        }
      });

      StackGroup<T, P> stackGroup = StackGroup(axisIndex, []);
      stackDataMap.forEach((key, value) {
        List<StackData<T, P>> dl = [];
        for (var ele in value) {
          dl.add(StackData<T, P>(true, index, ele, originInfo.parentMap[ele]!));
        }
        StackColumn<T, P> column = StackColumn(dl, true, originInfo.parentMap[value.first]!.strategy);
        stackGroup.column.add(column);
      });
      for (var data in singleDataList) {
        StackColumn<T, P> column = StackColumn(
          [StackData(false, index, data, originInfo.parentMap[data]!)],
          false,
          StackStrategy.all,
        );
        stackGroup.column.add(column);
      }
      groupList.add(stackGroup);
    });

    ///排序
    for (StackGroup group in groupList) {
      //排序孩子
      for (var child in group.column) {
        if (child.data.length > 1) {
          child.data.sort((a, b) {
            var ap = originInfo.parentMap[a.data];
            var bp = originInfo.parentMap[b.data];
            return originInfo.sortMap[ap]!.compareTo(originInfo.sortMap[bp]!);
          });
        }
      }
      //排序自身
      if (group.column.length > 1) {
        group.column.sort((a, b) {
          var ap = originInfo.parentMap[a.data.last.data]!;
          var bp = originInfo.parentMap[b.data.last.data]!;
          return originInfo.sortMap[ap]!.compareTo(originInfo.sortMap[bp]!);
        });
      }
    }
    return groupList;
  }

  ///收集极值信息
  Map<AxisIndex, List<num>> _collectExtreme(AxisGroup<T, P> axisGroup) {
    Map<AxisIndex, List<num>> map = {};
    axisGroup.groupMap.forEach((key, value) {
      List<num> list = [];
      map[key] = list;

      num minValue = double.infinity;
      num maxValue = double.negativeInfinity;
      for (var group in value) {
        for (var column in group.column) {
          for (var data in column.data) {
            var up = data.up;
            var down = data.down;
            minValue = min([minValue, down]);
            maxValue = max([maxValue, up]);
          }
        }
      }
      if (minValue.isFinite) {
        list.add(minValue);
      }
      if (maxValue.isFinite) {
        list.add(maxValue);
      }
    });
    return map;
  }

  ///解析数据
  ///将给定数据解析为类似于栈的数据
  ///并保存相关的数据信息
  AxisGroup<T, P> _parse() {
    ///解析原始数据信息
    _originInfo = _parseOriginInfo(_dataList);

    ///将数据安装使用的X坐标轴进行分割
    Map<AxisIndex, List<StackGroup<T, P>>> resultMap = _splitDataByAxis(_originInfo, _dataList);

    ///最后进行数据合并整理
    AxisGroup<T, P> group = AxisGroup(resultMap);
    group.mergeData();
    _extremeMap = _collectExtreme(group);
    return group;
  }

  int _computeBarCount(List<P> list) {
    int max = 0;
    for (P data in list) {
      if (data.data.length > max) {
        max = data.data.length;
      }
    }
    return max;
  }
}

class OriginInfo<T extends BaseItemData, P extends BaseGroupData<T>> {
  final Map<P, int> sortMap;

  final Map<T, P> parentMap;

  OriginInfo(this.sortMap, this.parentMap);
}
