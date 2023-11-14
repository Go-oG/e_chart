import 'package:e_chart/e_chart.dart';

///计算所有子节点的比例和
///当parent节点的数据>=children的数据和
///会出现无法占满的情况，因此需要归一化
double computeAllRatio(List<TreeMapData> list) {
  double area = 0;
  for (var element in list) {
    area += element.areaRatio;
  }
  return area;
}
