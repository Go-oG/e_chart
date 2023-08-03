import 'package:e_chart/e_chart.dart';

abstract class GridChild {
  ///返回指定坐标轴的列数
  int getAxisDataCount(int axisIndex, bool isXAxis);

  ///返回指定坐标轴上文字字符最多的文本
  DynamicText getAxisMaxText(int axisIndex, bool isXAxis) {
    List<DynamicData> dl = getAxisExtreme(axisIndex, isXAxis);
    if (dl.isEmpty) {
      return DynamicText.empty;
    }
    String text = dl.first.getText();
    for (var data in dl) {
      String str = data.getText();
      if (str.length > text.length) {
        text = str;
      }
    }
    return DynamicText(text);
  }

  ///返回指定坐标轴上的极值
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis);

}
