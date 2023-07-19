import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

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

  List<num> getExtreme(CoordSystem system, int axisIndex) {
    if (_extremeMap.isEmpty) {
      return [];
    }
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    AxisIndex index = AxisIndex(system, axisIndex);
    List<num> dl = _extremeMap[index] ?? [];
    return dl;
  }

  OriginInfo<T, P> _originInfo = OriginInfo({}, {});

  ///解析数据
  ///将给定数据解析为类似于栈的数据
  ///并保存相关的数据信息
  AxisGroup<T, P> _parse() {
    ///解析原始数据信息
    _originInfo = _parseOriginInfo(_dataList);

    ///将数据安装使用的X坐标轴进行分割
    Map<AxisIndex, List<StackData<T, P>>> resultMap = _splitDataByAxis(_originInfo, _dataList);

    ///最后进行数据合并整理
    AxisGroup<T, P> group = AxisGroup(resultMap);
    group.mergeData();
    _extremeMap = _collectExtreme(group);
    return group;
  }

  ///解析数据的原始信息
  ///包括子数据-父数据映射关系、
  ///排序索引
  OriginInfo<T, P> _parseOriginInfo(List<P> dataList) {
    Map<P, int> sortMap = {};
    Map<P, Map<int, Wrap<T, P>>> dataMap = {};

    each(dataList, (group, groupIndex) {
      if (!sortMap.containsKey(group)) {
        sortMap[group] = groupIndex;
      }
      Map<int, Wrap<T, P>> childMap = dataMap[group] ?? {};
      dataMap[group] = childMap;

      each(group.data, (childData, i) {
        childMap[i] = Wrap(childData, group, groupIndex, i);
      });
    });
    return OriginInfo(sortMap, dataMap);
  }

  ///将给定的数据按照其使用的X 坐标轴进行分割
  Map<AxisIndex, List<StackData<T, P>>> _splitDataByAxis(OriginInfo<T, P> originInfo, List<P> dataList) {
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in dataList) {
      int xIndex;
      CoordSystem system;
      if (_series.coordSystem == CoordSystem.polar) {
        system = CoordSystem.polar;
        xIndex = group.polarAxisIndex ?? _series.polarAxisIndex;
      } else {
        system = CoordSystem.grid;
        xIndex = group.xAxisIndex ?? _series.xAxisIndex;
      }
      if (xIndex < 0) {
        xIndex = 0;
      }
      AxisIndex index = AxisIndex(system, xIndex);
      if (!axisGroupMap.containsKey(index)) {
        axisGroupMap[index] = [];
      }
      axisGroupMap[index]!.add(group);
    }

    Map<AxisIndex, List<StackData<T, P>>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = _handleSingleAxis(key, value, originInfo);
    });
    return resultMap;
  }

  ///处理单根坐标轴
  List<StackData<T, P>> _handleSingleAxis(AxisIndex axisIndex, List<P> list, OriginInfo<T, P> originInfo) {
    int barGroupCount = _computeBarCount(list);

    ///存放分组数据
    List<List<InnerData<T, P>>> groupDataSetList = List.generate(barGroupCount, (index) => []);
    for (int i = 0; i < barGroupCount; i++) {
      for (var data in list) {
        if (i >= data.data.length) {
          continue;
        }
        groupDataSetList[i].add(InnerData(data.data[i], data));
      }
    }

    List<StackData<T, P>> stackGroupList = List.generate(barGroupCount, (index) => StackData(axisIndex, []));

    ///合并数据
    each(groupDataSetList, (group, index) {
      StackData<T, P> stackGroup = stackGroupList[index];

      ///<stackId>
      Map<String, List<Wrap<T, P>>> stackDataMap = {};
      List<Wrap<T, P>> singleDataList = [];
      each(group, (innerData, p1) {
        var wrap = originInfo.dataMap[innerData.parent]![index];
        if (wrap == null) {
          return;
        }
        if (wrap.parent.isStack) {
          var stackId = wrap.parent.stackId!;
          List<Wrap<T, P>> dl = stackDataMap[stackId] ?? [];
          stackDataMap[stackId] = dl;
          dl.add(wrap);
        } else {
          singleDataList.add(wrap);
        }
      });
      stackDataMap.forEach((key, value) {
        List<SingleData<T, P>> dl = List.from(value.map((e) => SingleData(e, true)));
        ColumnData<T, P> column = ColumnData(dl, true, value.first.parent.strategy);
        stackGroup.data.add(column);
      });
      each(singleDataList, (ele, i) {
        ColumnData<T, P> column = ColumnData([SingleData(ele, false)], false, StackStrategy.all);
        stackGroup.data.add(column);
      });
    });

    ///排序
    for (StackData group in stackGroupList) {
      //排序孩子
      for (var child in group.data) {
        if (child.data.length > 1) {
          child.data.sort((a, b) {
            var ai = a.wrap.groupIndex;
            var bi = b.wrap.groupIndex;
            return ai.compareTo(bi);
          });
        }
      }
      //排序自身
      if (group.data.length > 1) {
        group.data.sort((a, b) {
          var ai = a.data.first.wrap.groupIndex;
          var bi = b.data.first.wrap.groupIndex;
          return ai.compareTo(bi);
        });
      }
    }
    return stackGroupList;
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
        for (var column in group.data) {
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
  final Map<P, Map<int, Wrap<T, P>>> dataMap;

  OriginInfo(this.sortMap, this.dataMap);
}

class InnerData<T extends BaseItemData, P extends BaseGroupData<T>> {
  final T? data;
  final P parent;

  InnerData(this.data, this.parent);
}
