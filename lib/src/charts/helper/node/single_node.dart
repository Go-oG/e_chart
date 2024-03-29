import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 不可再分的最小绘制单元
/// 其用于极坐标系和二维坐标系下的节点位置表示
class SingleNode<T extends StackItemData, P extends StackGroupData<T>> with ViewStateProvider,ExtProps {
  final ColumnNode<T, P> parentNode;
  final WrapData<T, P> _wrap;

  ///标识是否是一个堆叠数据
  final bool stack;

  SingleNode(this.parentNode, this._wrap, this.stack);

  ///布局过程中使用的临时变量
  num _up = 0;

  num get up => _up;

  set up(num u) {
    _up = u;
    data?.stackUp = u;
  }

  num _down = 0;

  num get down => _down;

  set down(num d) {
    _down = d;
    data?.stackDown = d;
  }

  ///只在二维坐标系下使用
  Rect rect = Rect.zero;

  ///只在极坐标系下使用
  Arc arc = Arc();

  ///通用的节点位置，一般只有折线图和散点图使用
  Offset position = Offset.zero;

  ///临时记录样式相关的
  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  WrapData<T, P> get wrap => _wrap;

  T? get data => _wrap.data;

  P get parent => _wrap.parent;

  int get groupIndex => _wrap.groupIndex;

  int get dataIndex => _wrap.dataIndex;

  @override
  int get hashCode {
    return _wrap.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SingleNode) {
      return other._wrap == _wrap;
    }
    return false;
  }
}
