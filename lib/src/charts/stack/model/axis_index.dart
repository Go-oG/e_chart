import '../../../model/index.dart';

class AxisIndex {
  final CoordType system;
  ///轴索引,在垂直方向上其应该对应X轴 水平方向上应该对应Y轴索引
  final int axisIndex;
  const AxisIndex(this.system, this.axisIndex);

  @override
  int get hashCode {
    return Object.hash(system, axisIndex);
  }

  @override
  bool operator ==(Object other) {
    return other is AxisIndex && other.axisIndex == axisIndex && other.system == system;
  }
}