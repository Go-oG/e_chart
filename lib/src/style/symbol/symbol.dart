import 'dart:ui';

import '../../core/view_state.dart';

///Symbol实现
abstract class ChartSymbol {
  const ChartSymbol();

  Size get size;

  void draw(Canvas canvas, Paint paint, Offset center,double animator);

  ChartSymbol convert(Set<ViewState> states){
    return this;
  }

}

