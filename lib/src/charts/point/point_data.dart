import 'package:e_chart/e_chart.dart';

class PointData extends BaseItemData {
  dynamic x;
  dynamic y;
  dynamic value;

  PointData(this.x, this.y, this.value, {super.label, super.id}) {
    checkDataType(x);
    checkDataType(y);
  }
}
