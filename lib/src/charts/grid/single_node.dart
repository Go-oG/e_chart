import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/stack_data.dart';
import 'package:flutter/material.dart';

import 'base_data.dart';

/// 不可再分的最小绘制单元，
class SingleNode<T extends BaseItemData, P extends BaseGroupData<T>> with ViewStateProvider {
  final StackData<T, P> data;
  Rect rect = Rect.zero;
  Offset position = Offset.zero;

  SingleNode(this.data);

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
