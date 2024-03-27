import 'package:e_chart/e_chart.dart';

abstract class CoordChild {
  ///返回当前视图需要嵌入的坐标系信息
  CoordInfo getEmbedCoord();

  ///给定坐标系类型和对应坐标轴的维度信息，返回给定数据对应维度的值
  dynamic getDimData(CoordType type, AxisDim dim, dynamic data);

  ///返回指定坐标轴上文字字符最长的文本
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim);

  ///返回指定坐标轴的列数
  int getAxisDataCount(CoordType type, AxisDim dim);

  ///返回指定坐标轴上的极值
  Iterable<dynamic> getAxisExtreme(CoordType type, AxisDim axisDim);

  Iterable<dynamic> getViewPortAxisExtreme(CoordType type, AxisDim axisDim, BaseScale scale);

  ///同步滚动偏移量 一般用在笛卡尔坐标系里面实现手势滚动
  void syncScroll(CoordType type, double scrollX, double scrollY);
}
