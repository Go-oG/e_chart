import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 不可再分的最小绘制单元
/// 其用于极坐标系和二维坐标系下的节点位置表示
class SingleNode<T extends BaseItemData, P extends BaseGroupData<T>> with ViewStateProvider {
  final ColumnNode<T, P> parent;
  final SingleData<T, P> data;

  SingleNode(this.parent, this.data);

  ///只在二维坐标系下使用
  Rect rect = Rect.zero;

  ///只在极坐标系下使用
  Arc arc = Arc();

  ///通用的节点位置，一般只有折线图和散点图使用
  Offset position = Offset.zero;


  ///临时记录样式相关的
  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SingleNode) {
      return other.data == data;
    }
    return false;
  }

  num get up => data.up;

  num get down => data.down;
}
