import 'package:e_chart/e_chart.dart';

class PointGroup extends BaseGroupData<PointData> {
  int gridIndex;
  int gridXIndex;
  int gridYIndex;
  int polarIndex;
  int calendarIndex;

  PointGroup(
    super.data, {
    this.gridIndex = 0,
    this.gridXIndex = 0,
    this.gridYIndex = 0,
    this.polarIndex = -1,
    this.calendarIndex = 0,
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
