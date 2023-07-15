import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 不可再分的最小绘制单元，
class SingleNode<T extends BaseItemData, P extends BaseGroupData<T>> with ViewStateProvider {
  final ColumnNode<T, P> parent;
  final StackData<T, P> data;

  SingleNode(this.parent, this.data);

  Rect rect = Rect.zero;
  Offset position = Offset.zero;

  ///临时记录样式相关的
  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  @override
  int get hashCode {
    return data.data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SingleNode) {
      return other.data.data == data.data;
    }
    return false;
  }

  num get up => data.up;

  num get down => data.down;
}
