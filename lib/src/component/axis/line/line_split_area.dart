import 'dart:ui';

class LineSplitResult{
  final int index;
  final int maxIndex;
  final Offset center;
  final Offset start;
  final Offset end;

  LineSplitResult(this.index,this.maxIndex,this.center, this.start, this.end);

}