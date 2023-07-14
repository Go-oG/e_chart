import 'dart:ui';

import 'package:e_chart/src/charts/grid/group_node.dart';
import 'package:e_chart/src/model/stack_data.dart';

import 'base_data.dart';
import 'single_node.dart';

class ColumnNode<T extends BaseItemData, P extends BaseGroupData<T>> {
  final GroupNode<T, P> parent;
  final StackColumn<T, P> data;
  List<SingleNode<T, P>> nodeList = [];

  Rect rect = Rect.zero;

  ColumnNode(this.parent, this.data);

  num getUp() {
    return nodeList[nodeList.length - 1].data.up;
  }

  num getDown() {
    return nodeList[0].data.down;
  }
}
