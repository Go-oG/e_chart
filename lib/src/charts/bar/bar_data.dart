import 'package:e_chart/e_chart.dart';

class BarGroupData extends StackGroupData<StackItemData, BarGroupData> {
  BarGroupData(
    super.data, {
    super.domainAxis,
    super.valueAxis,
    super.id,
    super.name,
    super.barSize,
    super.barMaxSize,
    super.barMinSize,
    super.stackId,
    super.styleIndex,
  });
}

///该数据用于实现瀑布图(柱状图模拟)
class WaterFallData extends StackItemData{

  num upValue;
  num downValue;

  WaterFallData(dynamic domain,this.upValue,this.downValue):super(domain,upValue);

  @override
  num get maxValue => upValue;

  @override
  num get minValue => downValue;

}
