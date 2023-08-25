import 'dart:ui';

import 'package:e_chart/e_chart.dart';


class TreeMapNode extends TreeNode<TreeMapNode> with ViewStateProvider {
  final TreeData data;
  NodeProps cur = NodeProps(); // 当前对象
  NodeProps start = NodeProps(); //动画开始帧
  NodeProps end = NodeProps(); //动画结束帧

  TreeMapNode(super.parent, this.data, {super.deep, super.maxDeep, super.value}) {
    setExpand(false, false);
  }

  ///计算面积比
  double get areaRatio {
    if (parent == null) {
      return 1;
    }
    return value / parent!.value;
  }

  setPosition(Rect rect) {
    x = rect.center.dx;
    y = rect.center.dy;
    size = rect.size;
    cur.position = rect;
  }

  Rect getPosition(){return cur.position;}

}

class NodeProps {
  Rect position = Rect.zero; //当前位置参数

  NodeProps copy() {
    NodeProps p = NodeProps();
    p.position = position;
    return p;
  }
}
