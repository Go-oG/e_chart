import 'package:flutter/cupertino.dart';

class ChartEdgeInset {
  double left = 0;
  double top = 0;
  double right = 0;
  double bottom = 0;

  void clear() {
    left = top = right = bottom = 0;
  }

  double get vertical => top + bottom;

  double get horizontal => left + right;

}
