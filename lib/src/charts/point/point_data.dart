import 'package:e_chart/e_chart.dart';

class PointGroup extends BaseGroupData<PointData> {
  ///标识使用的坐标轴索引
  ///对应Polar坐标系 X轴对应半径轴 Y轴对应角度轴
  int xAxisIndex;
  int yAxisIndex;

  PointGroup(
    super.data, {
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    super.id,
    super.name,
  });
}

class PointData extends BaseItemData {
  dynamic x;
  dynamic y;
  dynamic value;

  PointData(this.x, this.y, this.value, {super.name, super.id}) {
    checkDataType(x);
    checkDataType(y);
  }
}
