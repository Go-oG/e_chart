import 'package:e_chart/e_chart.dart';

class AxisIndex {
  final CoordSystem system;
  ///X 轴索引
  final int xIndex;
  const AxisIndex(this.system, this.xIndex);

  @override
  int get hashCode {
    return Object.hash(system, xIndex);
  }

  @override
  bool operator ==(Object other) {
    return other is AxisIndex && other.xIndex == xIndex && other.system == system;
  }
}

///存储数据处理结果
class AxisGroup<T extends BaseItemData, P extends BaseGroupData<T>> {
  ///存储不同坐标轴的数据
  final Map<AxisIndex, List<StackData<T, P>>> groupMap;

  const AxisGroup(this.groupMap);

  void mergeData() {
    groupMap.forEach((key, value) {
      for (var ele in value) {
        ele.mergeData();
      }
    });
  }

  int getColumnCount(AxisIndex index) {
    List<StackData>? group = groupMap[index];
    if (group == null) {
      return 1;
    }
    int count = 0;
    for (StackData sg in group) {
      if (sg.data.length > count) {
        count = sg.data.length;
      }
    }
    if (count == 0) {
      return 1;
    }
    return count;
  }
}

class StackData<T extends BaseItemData, P extends BaseGroupData<T>> {
  final AxisIndex index;
  final List<ColumnData<T, P>> data;

  StackData(this.index, this.data);

  void mergeData() {
    for (var col in data) {
      col.mergeData();
    }
  }
}

class ColumnData<T extends BaseItemData, P extends BaseGroupData<T>> {
  final bool isStack;
  final List<SingleData<T, P>> data;
  final StackStrategy strategy;

  ColumnData(this.data, this.isStack, this.strategy);

  void mergeData() {
    num up = 0;
    for (int i = 0; i < data.length; i++) {
      var cd = data[i];
      var itemData = cd.data;
      if (itemData == null) {
        cd.up = up;
        continue;
      }
      if (i == 0) {
        if (strategy == StackStrategy.all ||
            strategy == StackStrategy.samesign ||
            (strategy == StackStrategy.positive && itemData.up > 0 && isStack) ||
            (strategy == StackStrategy.negative && itemData.up < 0 && isStack)) {
          up = itemData.up;
          cd.up = itemData.up;
          cd.down = itemData.down;
        }
      } else {
        if (strategy == StackStrategy.all ||
            (strategy == StackStrategy.samesign && (itemData.up <= 0 && up <= 0 || (itemData.up >= 0 && up >= 0))) ||
            (strategy == StackStrategy.positive && itemData.up > 0) ||
            (strategy == StackStrategy.negative && itemData.up < 0)) {
          cd.down = up;
          cd.up = up + (itemData.up - itemData.down);
          up = cd.up;
        }
      }
    }
  }

}

class SingleData<T extends BaseItemData, P extends BaseGroupData<T>> {
  final Wrap<T, P> _wrap;

  ///标识是否是一个堆叠数据
  final bool stack;

  num up = 0;

  num down = 0;

  List<double> hRatio = [];
  List<double> vRatio = [];

  SingleData(this._wrap, this.stack);

  Wrap<T, P> get wrap => _wrap;

  T? get data => _wrap.data;

  P get parent => _wrap.parent;

  int get groupIndex => _wrap.groupIndex;

  int get dataIndex => _wrap.dataIndex;

  @override
  int get hashCode {
    return Object.hash(parent, data);
  }

  @override
  bool operator ==(Object other) {
    if (other is! SingleData) {
      return false;
    }
    return other.parent == parent && other.data == data;
  }
}

class Wrap<T extends BaseItemData, P extends BaseGroupData<T>> {
  final T? data;
  final P parent;

  ///标识该数据所属的Group组的序号
  final int groupIndex;

  ///标识该数据在其Group中的位置
  final int dataIndex;

  Wrap(this.data, this.parent, this.groupIndex, this.dataIndex);
}
