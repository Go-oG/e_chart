import 'dart:ui';

class LineSplitResult{
  final dynamic data;
  final int index;
  final int maxIndex;
  final Offset center;
  final Offset start;
  final Offset end;

  LineSplitResult(this.data,this.index,this.maxIndex,this.center, this.start, this.end);

}