import 'dart:ui';

///绘制图元的抽象表示
abstract class Shape {

  const Shape();

  ///返回对应的Path
  ///是否封闭由图形自身决定
  Path toPath();

  bool get isClosed;

  bool contains(Offset offset);
}

