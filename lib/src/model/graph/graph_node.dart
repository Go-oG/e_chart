import 'package:e_chart/e_chart.dart';

class GraphNode extends BaseItemData with ExtProps, ViewStateProvider {
  ///节点索引
  int index = 0;

  ///当前X位置(中心位置)
  double x = double.nan;

  ///当前Y位置(中心位置)
  double y = double.nan;

  ///给定的固定位置
  double? fx;
  double? fy;

  ///宽高
  double width = 0;
  double height = 0;

  ///半径
  num r = 0;

  /// 当前X方向速度分量
  double vx = 0;

  /// 当前Y方向速度分量
  double vy = 0;

  ///权重值
  num weight = 0;

  dynamic data;

  GraphNode({super.id, super.label, this.data});

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return (other is GraphNode) && (other.id == id);
  }

  @override
  String toString() {
    return 'x:${x.toStringAsFixed(0)} y:${y.toStringAsFixed(0)} r:${r.toStringAsFixed(2)} w:${width.toStringAsFixed(2)} h:${height.toStringAsFixed(2)}';
  }
}
