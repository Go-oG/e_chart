import 'dart:ui';

import '../../../core/disposable.dart';

class LineResult extends Disposable{
  final int index;
  final int maxIndex;
  final Offset start;
  final Offset end;

  LineResult(this.index, this.maxIndex, this.start, this.end);
}