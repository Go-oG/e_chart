import 'package:e_chart/e_chart.dart';

import 'data_store.dart';

///存储数据处理结果
class AxisGroup<T extends StackItemData, P extends StackGroupData<T,P>> {
  ///存储不同坐标轴的数据
  Map<AxisIndex, List<GroupNode<T, P>>> groupMap;

  ///按照主轴索引存储的数据
  Map<AxisIndex, DataStore<StackData<T, P>>> storeMap = {};

  AxisGroup(this.groupMap);

  void mergeData(Direction direction) {
    groupMap.forEach((key, value) {
      List<StackData<T, P>> nodeList = [];
      for (var ele in value) {
        ele.mergeData();
        for (var col in ele.nodeList) {
          nodeList.addAll(col.nodeList);
        }
      }
      DataStore<StackData<T, P>> store = DataStore(nodeList, (data) {
        if (direction == Direction.vertical) {
          return data.dataNull?.x;
        }
        return data.dataNull?.y;
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

  void dispose() {
    var old=storeMap;
    storeMap={};
    old.forEach((key, value) {
      value.dispose();
    });

    var old2=groupMap;
    groupMap = {};
    for (var gl in old2.values) {
      each(gl, (p0, p1) {
        p0.dispose();
      });
    }
  }
}
