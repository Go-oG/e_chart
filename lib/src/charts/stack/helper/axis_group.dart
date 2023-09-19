import '../../../model/index.dart';
import '../index.dart';
import 'data_store.dart';

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
