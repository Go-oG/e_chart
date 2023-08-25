import 'dart:ui';

abstract class Shape {
  Path toPath(bool close);

  bool contains(Offset offset);

}
