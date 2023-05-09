import 'dart:ui';

abstract class DrawNode {
  void measure(double parentWidth,double parentHeight);

  void layout(double left, double top, double right, double bottom);

  void draw(Canvas canvas);

}
