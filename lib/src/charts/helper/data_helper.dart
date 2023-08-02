import 'package:e_chart/e_chart.dart';

///处理二维坐标系下堆叠数据
///只针对数字类型处理
class DataHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends ChartSeries> {
  final List<P> _dataList;
  final S _series;
  final Direction direction;
  late AxisGroup<T, P> _result;

  DataHelper(this._series, this._dataList, this.direction) {
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
    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = _splitDataByAxis(_originInfo, _dataList);

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
    Map<P, Map<int, WrapData<T, P>>> dataMap = {};

    each(dataList, (group, groupIndex) {
      if (!sortMap.containsKey(group)) {
        sortMap[group] = groupIndex;
      }
      Map<int, WrapData<T, P>> childMap = dataMap[group] ?? {};
      dataMap[group] = childMap;

      each(group.data, (childData, i) {
        childMap[i] = WrapData(childData, group, groupIndex, i);
      });
    });
    return OriginInfo(sortMap, dataMap);
  }

  ///将给定的数据按照其使用的X坐标轴进行分割
  Map<AxisIndex, List<GroupNode<T, P>>> _splitDataByAxis(OriginInfo<T, P> originInfo, List<P> dataList) {
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in dataList) {
      int axisIndex;
      CoordSystem system;
      if (_series.coordSystem == CoordSystem.polar) {
        system = CoordSystem.polar;
        axisIndex = _series.polarIndex;
      } else {
        system = CoordSystem.grid;
        if (direction == Direction.vertical) {
          axisIndex = group.xAxisIndex;
        } else {
          axisIndex = group.yAxisIndex;
        }
      }
      if (axisIndex < 0) {
        axisIndex = 0;
      }

      AxisIndex index = AxisIndex(system, axisIndex);
      if (!axisGroupMap.containsKey(index)) {
        axisGroupMap[index] = [];
      }
      axisGroupMap[index]!.add(group);
    }

    Map<AxisIndex, List<GroupNode<T, P>>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = _handleSingleAxis(key, value, originInfo);
    });
    return resultMap;
  }

  ///处理单根坐标轴
  List<GroupNode<T, P>> _handleSingleAxis(AxisIndex axisIndex, List<P> list, OriginInfo<T, P> originInfo) {
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
    List<GroupNode<T, P>> groupNodeList = List.generate(barGroupCount, (index) => GroupNode(axisIndex, []));

    ///合并数据
    each(groupDataSetList, (group, index) {
      GroupNode<T, P> groupNode = groupNodeList[index];

      ///<stackId>
      Map<String, List<WrapData<T, P>>> singleNodeMap = {};

      List<WrapData<T, P>> singleNodeList = [];
      each(group, (innerData, p1) {
        var wrap = originInfo.dataMap[innerData.parent]![index];
        if (wrap == null) {
          return;
        }
        if (wrap.parent.isStack) {
          var stackId = wrap.parent.stackId!;
          List<WrapData<T, P>> dl = singleNodeMap[stackId] ?? [];
          singleNodeMap[stackId] = dl;
          dl.add(wrap);
        } else {
          singleNodeList.add(wrap);
        }
      });

      singleNodeMap.forEach((key, value) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], true, value.first.parent.strategy);
        List<SingleNode<T, P>> dl = List.from(value.map((e) => SingleNode(column, e, true)));
        column.nodeList.addAll(dl);
        groupNode.nodeList.add(column);
      });
      each(singleNodeList, (ele, i) {
        ColumnNode<T, P> column = ColumnNode(groupNode, [], false, StackStrategy.all);
        var singleNode = SingleNode(column, ele, false);
        column.nodeList.add(singleNode);
        groupNode.nodeList.add(column);
      });
    });

    ///排序
    for (GroupNode group in groupNodeList) {
      //排序孩子
      for (var child in group.nodeList) {
        if (child.nodeList.length > 1) {
          child.nodeList.sort((a, b) {
            var ai = a.groupIndex;
            var bi = b.groupIndex;
            return ai.compareTo(bi);
          });
        }
      }
      //排序自身
      if (group.nodeList.length > 1) {
        group.nodeList.sort((a, b) {
          var ai = a.nodeList.first.groupIndex;
          var bi = b.nodeList.first.groupIndex;
          return ai.compareTo(bi);
        });
      }
    }
    return groupNodeList;
  }

  ///收集极值信息(其应该是Y轴)
  Map<AxisIndex, List<num>> _collectExtreme(AxisGroup<T, P> axisGroup) {
    CoordSystem system = _series.coordSystem ?? CoordSystem.grid;
    bool polar = system == CoordSystem.polar;
    bool vertical = direction == Direction.vertical;

    Map<int, num> minMap = {};
    Map<int, num> maxMap = {};

    axisGroup.groupMap.forEach((key, value) {
      for (var group in value) {
        for (var column in group.nodeList) {
          for (var data in column.nodeList) {
            var up = data.up;
            var down = data.down;
            var group = data.parent;
            int index;
            if (polar) {
              index = _series.polarIndex;
            } else {
              index = vertical ? group.yAxisIndex : group.xAxisIndex;
            }
            num minValue = minMap[index] ?? double.infinity;
            num maxValue = maxMap[index] ?? double.negativeInfinity;
            minValue = min([minValue, down]);
            maxValue = max([maxValue, up]);
            minMap[index] = minValue;
            maxMap[index] = maxValue;
          }
        }
      }
    });
    Map<AxisIndex, List<num>> map = {};
    minMap.forEach((key, value) {
      map[AxisIndex(system, key)] = [value];
    });

    maxMap.forEach((key, value) {
      var axis = AxisIndex(system, key);
      List<num> list = map[axis] ?? [];
      map[axis] = list;
      list.add(value);
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
  final Map<P, Map<int, WrapData<T, P>>> dataMap;

  OriginInfo(this.sortMap, this.dataMap);
}

class InnerData<T extends BaseItemData, P extends BaseGroupData<T>> {
  final T? data;
  final P parent;

  InnerData(this.data, this.parent);
}
