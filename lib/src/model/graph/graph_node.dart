import 'package:flutter/widgets.dart';
import 'package:xutil/xutil.dart';

class GraphNode with ExtProps{
  ///ID 唯一ID
  final String id;

  ///节点索引
  int index = 0;

  ///当前X位置
  double x = 0;

  ///当前Y位置
  double y = 0;

  ///给定的固定位置
  double? fx;
  double? fy;

  /// 当前X方向速度分量
  double vx = 0;

  /// 当前Y方向速度分量
  double vy = 0;

  ///半径
  num r = 0;

  ///权重值
  num weight = 0;

  GraphNode(this.id) {
    if (id.isEmpty) {
      throw FlutterError('id不能为空');
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return (other is GraphNode) && (other.id == id);
  }
}
