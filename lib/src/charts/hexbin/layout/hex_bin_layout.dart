import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class HexbinLayout {

  void onLayout(List<HexbinNode> data, LayoutType type, HexbinLayoutParams params);

  //计算Hex(0，0，0)节点的中心位置(其它节点需要根据该节点位置来计算当前位置)
  ///子类可以复写该方法实现不同的位置中心
  Offset computeZeroCenter(HexbinLayoutParams params) {
    var center = params.series.center;
    return Offset(center[0].convert(params.width), center[1].convert(params.height));
  }

}

class HexbinLayoutParams {
  final HexbinSeries series;
  final double width;
  final double height;
  final double radius;

  ///子类可以更改该字段
  bool flat;

  HexbinLayoutParams(this.series, this.width, this.height, this.radius, this.flat);
}
