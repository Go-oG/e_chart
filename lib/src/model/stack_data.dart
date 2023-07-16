import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_data.dart';

class AxisIndex {
  final int index;

  const AxisIndex(this.index);

  @override
  int get hashCode {
    return index.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is AxisIndex && other.index == index;
  }
}

class AxisGroup<T extends BaseItemData, P extends BaseGroupData<T>> {
  final Map<AxisIndex, List<StackGroup<T, P>>> groupMap;

  const AxisGroup(this.groupMap);

  void mergeData() {
    groupMap.forEach((key, value) {
      for (var ele in value) {
        ele.mergeData();
      }
    });
    // groupMap.forEach((key, value) {
    //   value.removeWhere((ele) => ele.column.isEmpty);
    // });
    // groupMap.removeWhere((key, value) => value.isEmpty);
  }

  int getColumnCount(AxisIndex index) {
    List<StackGroup>? group = groupMap[index];
    if (group == null) {
      return 1;
    }
    int count = 0;
    for (StackGroup sg in group) {
      if (sg.column.length > count) {
        count = sg.column.length;
      }
    }
    if (count == 0) {
      return 1;
    }
    return count;
  }
}

class StackGroup<T extends BaseItemData, P extends BaseGroupData<T>> {
  final AxisIndex index;
  final List<StackColumn<T, P>> column;

  StackGroup(this.index, this.column);

  void mergeData() {
    for (var col in column) {
      col.mergeData();
    }
  }
}

class StackColumn<T extends BaseItemData, P extends BaseGroupData<T>> {
  final bool isStack;
  final List<StackData<T, P>> data;
  final StackStrategy strategy;

  StackColumn(this.data, this.isStack, this.strategy);

  void mergeData() {
    num up = 0;
    Set<StackData> remainSet = {};
    each(data, (itemData, i) {
      if (i == 0) {
        if (strategy == StackStrategy.all ||
            strategy == StackStrategy.samesign ||
            (strategy == StackStrategy.positive && itemData.data.up > 0 && isStack) ||
            (strategy == StackStrategy.negative && itemData.data.up < 0 && isStack)) {
          remainSet.add(itemData);
          itemData.up = itemData.data.up;
          itemData.down = itemData.data.down;
          up = itemData.up;
        }
      } else {
        if (strategy == StackStrategy.all ||
            (strategy == StackStrategy.samesign && (itemData.data.up <= 0 && up <= 0 || (itemData.data.up >= 0 && up >= 0))) ||
            (strategy == StackStrategy.positive && itemData.data.up > 0) ||
            (strategy == StackStrategy.negative && itemData.data.up < 0)) {
          remainSet.add(itemData);
          itemData.down = up;
          itemData.up = up + (itemData.data.up - itemData.data.down);
          up = itemData.up;
        }
      }
    });
  }
}

class StackData<T, P> {
  ///标识是否是一个堆叠数据
  final bool stack;

  ///标识该数据所属的Group组的序号
  final int groupIndex;

  ///标识该数据在其Group中的位置
  final int dataIndex;
  final T data;
  final P parent;
  num up = 0;
  num down = 0;

  StackData(
    this.stack,
    this.data,
    this.parent,
    this.groupIndex,
    this.dataIndex,
  );

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is StackData && other.data == data;
  }
}