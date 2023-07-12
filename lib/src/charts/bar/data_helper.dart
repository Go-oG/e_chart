import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/stack_data.dart';

///处理堆叠数据
class DataHelper {
  ///解析并处理数据
  AxisGroup parse(BarSeries series, List<GridGroupData> list) {
    Map<String, int> sortMap = {};
    Map<GridItemData, GridGroupData> parentMap = {};

    each(list, (p0, p1) {
      if (!sortMap.containsKey(p0.id)) {
        sortMap[p0.id] = p1;
      }

      for (var ele in p0.data) {
        parentMap[ele] = p0;
      }
    });

    ///<xAxisIndex>
    Map<AxisIndex, List<GridGroupData>> axisGroupMap = {};
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

    Map<AxisIndex, List<StackGroup>> resultMap = {};
    axisGroupMap.forEach((key, value) {
      resultMap[key] = parseStep2(key, value, parentMap, sortMap);
    });

    AxisGroup group = AxisGroup(resultMap);
    group.mergeData();
    return group;
  }

  static List<StackGroup> parseStep2(
    AxisIndex axisIndex,
    List<GridGroupData> list,
    Map<GridItemData, GridGroupData> parentMap,
    Map<String, int> sortMap,
  ) {
    int barGroupCount = _computeBarCount(list);
    List<List<GridItemData>> itemList = List.generate(barGroupCount, (index) => []);
    for (int i = 0; i < barGroupCount; i++) {
      for (var data in list) {
        if (data.data.length <= i) {
          continue;
        }
        itemList[i].add(data.data[i]);
      }
    }

    List<StackGroup> groupList = [];

    ///合并数据
    each(itemList, (group, index) {
      ///<stackId>
      Map<String, List<GridItemData>> stackDataMap = {};
      List<GridItemData> singleDataList = [];
      each(group, (data, p1) {
        var parent = parentMap[data]!;
        if (parent.isStack) {
          List<GridItemData> dl = stackDataMap[parent.stackId!] ?? [];
          stackDataMap[parent.stackId!] = dl;
          dl.add(data);
        } else {
          singleDataList.add(data);
        }
      });

      StackGroup stackGroup = StackGroup(axisIndex, []);
      stackDataMap.forEach((key, value) {
        List<StackData> dl=[];
        for (var ele in value) {
          dl.add(StackData(index, ele, parentMap[ele]!));
        }
        StackColumn column = StackColumn(dl, true, parentMap[value.first]!.strategy);
        stackGroup.column.add(column);
      });
      for (var data in singleDataList) {
        StackColumn column = StackColumn([StackData(index, data, parentMap[data]!)], false, StackStrategy.all);
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

  static int _computeBarCount(List<GridGroupData> list) {
    int max = 0;
    for (GridGroupData data in list) {
      if (data.data.length > max) {
        max = data.data.length;
      }
    }
    return max;
  }
}
