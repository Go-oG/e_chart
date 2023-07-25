import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../functions.dart';
import 'gesture_event.dart';

typedef EventCallback<T> = void Function(T);

abstract class ChartGesture {
  EventCallback<NormalEvent>? click;

  EventCallback<NormalEvent>? doubleClick;

  EventCallback<NormalEvent>? longPressStart;
  EventCallback<LongPressMoveEvent>? longPressMove;
  VoidCallback? longPressEnd;

  EventCallback<NormalEvent>? hoverStart;
  EventCallback<NormalEvent>? hoverMove;
  EventCallback<NormalEvent>? hoverEnd;

  EventCallback<NormalEvent>? dragStart;
  EventCallback<NormalEvent>? dragMove;
  VoidCallback? dragEnd;

  EventCallback<NormalEvent>? scaleStart;
  EventCallback<ScaleEvent>? scaleUpdate;
  VoidCallback? scaleEnd;

  Fun2<Offset, bool>? edgeFun;

  bool isInArea(Offset globalOffset);

  void clear() {
    click = null;
    doubleClick = null;

    longPressStart = null;
    longPressMove = null;

    longPressEnd = null;

    hoverStart = null;
    hoverMove = null;
    hoverEnd = null;
    dragEnd = null;
    dragMove = null;
    dragStart = null;
    scaleStart = null;
    scaleUpdate = null;
    scaleEnd = null;
  }
}

class RectGesture extends ChartGesture {
  Rect rect = Rect.zero;

  @override
  bool isInArea(Offset globalOffset) {
    if (edgeFun != null) {
      return edgeFun!.call(globalOffset);
    }
    return rect.contains(globalOffset);
  }
}

class ArcGesture extends ChartGesture {
  num innerRadius = 0;
  num outerRadius = 0;
  num startAngle = 0;
  num sweepAngle = 0;
  Offset center = Offset.zero;

  @override
  bool isInArea(Offset globalOffset) {
    if (edgeFun != null) {
      return edgeFun!.call(globalOffset);
    }
    return globalOffset.inSector(innerRadius, outerRadius, startAngle, sweepAngle);
  }
}
