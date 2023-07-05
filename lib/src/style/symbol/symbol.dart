import 'dart:ui';

import '../../core/view_state.dart';

///Symbol实现
abstract class ChartSymbol {
  Offset _center = Offset.zero;

  ChartSymbol({Offset center = Offset.zero}) {
    _center = center;
  }

  Offset get center => _center;

  set center(Offset o) => _center = o;

  Size get size;

  void draw(Canvas canvas, Paint paint,Offset c, double animator);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }

  bool internal(Offset point);
}
