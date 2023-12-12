import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class ElementRender extends Disposable{

  void draw(CCanvas canvas,Paint paint);
}