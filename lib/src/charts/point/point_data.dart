import 'package:e_chart/src/model/data.dart';

class PointData extends BaseItemData{
   DynamicData x;
   DynamicData y;
   DynamicData value;
   PointData(this.x, this.y,this.value, {super.label,super.id});
}
