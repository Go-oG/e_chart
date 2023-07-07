import '../../model/dynamic_data.dart';

abstract class GridChild {
  ///返回访问的X轴索引
  int get gridX;

  ///返回访问的轴索引
  int get gridY;

  ///返回X轴方向的数据数
  int get gridXDataCount;

  ///返回Y轴方向的数据数
  int get gridYDataCount;

  ///返回X轴方向上的极值
  List<DynamicData> get gridXExtreme;

  ///返回轴方向上的极值
  List<DynamicData> get gridYExtreme;
}
