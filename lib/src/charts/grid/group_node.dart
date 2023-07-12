import 'dart:ui';

import '../../core/view_state.dart';
import '../../model/index.dart';
import 'base_data.dart';
import 'column_node.dart';

///表示为系列数据
class GroupNode<T extends BaseItemData,P extends BaseGroupData<T>> with ViewStateProvider {
  final StackGroup<T,P> group;

  List<ColumnNode<T,P>> nodeList = [];

  GroupNode(this.group);

  Rect rect = Rect.zero;

  DynamicData getX() {
    return nodeList[0].data.data[0].data.x;
  }
}
