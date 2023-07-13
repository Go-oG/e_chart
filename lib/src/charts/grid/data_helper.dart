import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_data.dart';
import 'package:e_chart/src/model/stack_data.dart';

///处理堆叠数据
class DataHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends ChartSeries> {
  ///解析并处理数据
  AxisGroup<T, P> parse(S series, List<P> list) {
    Map<String, int> sortMap = {};
    Map<T, P> parentMap = {};

    each(list, (p0, p1) {
      if (!sortMap.containsKey(p0.id)) {
        sortMap[p0.id] = p1;
      }

      for (var ele in p0.data) {
        parentMap[ele] = p0;
      }
    });

    ///<xAxisIndex>
    Map<AxisIndex, List<P>> axisGroupMap = {};
    for (var group in list) {
      int xIndex = group.xAxisIndex ?? series.xAxisIndex;
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
      resultMap[key] = _parseStep2(key, value, parentMap, sortMap);
    });

    AxisGroup<T, P> group = AxisGroup(resultMap);
    group.mergeData();
    return group;
  }

  List<StackGroup<T, P>> _parseStep2(
    AxisIndex axisIndex,
    List<P> list,
    Map<T, P> parentMap,
    Map<String, int> sortMap,
  ) {
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
        var parent = parentMap[data]!;
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
          dl.add(StackData<T, P>(index, ele, parentMap[ele]!));
        }
        StackColumn<T, P> column = StackColumn(dl, true, parentMap[value.first]!.strategy);
        stackGroup.column.add(column);
      });
      for (var data in singleDataList) {
        StackColumn<T, P> column = StackColumn([StackData(index, data, parentMap[data]!)], false, StackStrategy.all);
        stackGroup.column.add(column);
      }
      groupList.add(stackGroup);
    });

    //排序
    for (StackGroup group in groupList) {
      //排序孩子
      for (var child in group.column) {
        if (child.data.length > 1) {
          child.data.sort((a, b) {
            var ap = parentMap[a.data]!.id;
            var bp = parentMap[b.data]!.id;
            return sortMap[ap]!.compareTo(sortMap[bp]!);
          });
        }
      }

      //排序自身
      if (group.column.length > 1) {
        group.column.sort((a, b) {
          var ap = parentMap[a.data.last.data]!;
          var bp = parentMap[b.data.last.data]!;
          return sortMap[ap.id]!.compareTo(sortMap[bp.id]!);
        });
      }
    }
    return groupList;
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

  //========================
  List<num> getExtreme(int axisIndex, S series, List<P> list) {
    if (list.isEmpty) {
      return [];
    }
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    List<P> groupList = [];
    Map<T, P> parentMap = {};

    for (var group in list) {
      int xIndex = group.xAxisIndex ?? series.xAxisIndex;
      if (xIndex < 0) {
        xIndex = 0;
      }
      if (xIndex != axisIndex) {
        continue;
      }
      groupList.add(group);

      for (var element in group.data) {
        parentMap[element] = group;
      }
    }

    List<StackGroup<T, P>> rl = _getExtremeStep2(AxisIndex(axisIndex), groupList, parentMap);
    each(rl, (group, p1) {
      group.mergeData();
    });
    if (rl.isEmpty) {
      return [];
    }

    num minValue = double.infinity;
    num maxValue = double.negativeInfinity;
    for (var group in rl) {
      for (var column in group.column) {
        for (var data in column.data) {
          var up = data.up;
          var down = data.down;
          minValue = min([minValue, down]);
          maxValue = max([maxValue, up]);
        }
      }
    }
    List<num> dl = [];
    if (minValue.isFinite) {
      dl.add(minValue);
    }
    if (maxValue.isFinite) {
      dl.add(maxValue);
    }
    return dl;
  }

  List<StackGroup<T, P>> _getExtremeStep2(AxisIndex axisIndex, List<P> list, Map<T, P> parentMap) {
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
        var parent = parentMap[data]!;
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
          dl.add(StackData<T, P>(index, ele, parentMap[ele]!));
        }
        StackColumn<T, P> column = StackColumn(dl, true, parentMap[value.first]!.strategy);
        stackGroup.column.add(column);
      });
      for (var data in singleDataList) {
        StackColumn<T, P> column = StackColumn([StackData(index, data, parentMap[data]!)], false, StackStrategy.all);
        stackGroup.column.add(column);
      }
      groupList.add(stackGroup);
    });
    return groupList;
  }
}
