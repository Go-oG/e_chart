import 'dart:ui';

import 'package:e_chart/src/charts/grid/node/group_node.dart';
import 'package:e_chart/src/charts/grid/stack_data.dart';

import '../../../shape/arc.dart';
import '../base_data.dart';
import 'single_node.dart';

class ColumnNode<T extends BaseItemData, P extends BaseGroupData<T>> {
  final GroupNode<T, P> parent;
  final ColumnData<T, P> data;
  List<SingleNode<T, P>> nodeList = [];

  Rect rect = Rect.zero;

  Arc arc=Arc();

  ColumnNode(this.parent, this.data);

  num getUp() {
    if(nodeList.isEmpty){return 0;}
    return nodeList[nodeList.length - 1].data.up;
  }

  num getDown() {
    if(nodeList.isEmpty){return 0;}
    return nodeList[0].data.down;
  }

}
