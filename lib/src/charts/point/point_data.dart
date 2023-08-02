import 'package:e_chart/src/model/data.dart';

class PointData extends ItemData{
   DynamicData x;
   DynamicData y;
   PointData(this.x, this.y, {super.label,super.id,super.value});
}
