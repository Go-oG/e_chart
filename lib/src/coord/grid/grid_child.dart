import 'package:e_chart/src/model/dynamic_text.dart';

import '../../model/dynamic_data.dart';

abstract class GridChild {

  ///返回指定坐标轴的列数
  int getAxisDataCount(int axisIndex, bool isXAxis);

  ///返回指定坐标轴上文字长度最大的文本
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis);

  ///返回指定坐标轴上的极值
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis);

}
