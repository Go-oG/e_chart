import '../stack_data.dart';
import '../node/group_node.dart';
import 'axis_index.dart';

///存储数据处理结果
class AxisGroup<T extends StackItemData, P extends StackGroupData<T>> {
  ///存储不同坐标轴的数据
  final Map<AxisIndex, List<GroupNode<T, P>>> groupMap;

  const AxisGroup(this.groupMap);

  void mergeData() {
    groupMap.forEach((key, value) {
      for (var ele in value) {
        ele.mergeData();
      }
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
