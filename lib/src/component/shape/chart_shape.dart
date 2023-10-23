import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///绘制图元的抽象表示
abstract class Shape extends Disposable {
  Shape();

  ///返回对应的Path
  ///是否封闭由图形自身决定
  Path toPath();

  bool get isClosed;

  bool contains(Offset offset);
}
