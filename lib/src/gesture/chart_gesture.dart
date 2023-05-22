import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../functions.dart';
import 'gesture_event.dart';

typedef EventCallback<T> = void Function(T);

abstract class ChartGesture {
  EventCallback<NormalEvent>? click;
  EventCallback<NormalEvent>? clickDown;
  EventCallback<NormalEvent>? clickUp;
  VoidCallback? clickCancel;

  EventCallback<NormalEvent>? doubleClick;
  EventCallback<NormalEvent>? doubleClickDown;
  EventCallback<NormalEvent>? doubleClickUp;
  VoidCallback? doubleClickCancel;

  EventCallback<NormalEvent>? longPressStart;
  EventCallback<LongPressMoveEvent>? longPressMove;
  EventCallback<NormalEvent>? longPressEnd;
  VoidCallback? longPressCancel;

  EventCallback<NormalEvent>? hoverStart;
  EventCallback<NormalEvent>? hoverMove;
  EventCallback<NormalEvent>? hoverEnd;

  EventCallback<NormalEvent>? verticalDragStart;
  EventCallback<NormalEvent>? verticalDragMove;
  EventCallback<VelocityEvent>? verticalDragEnd;
  VoidCallback? verticalDragCancel;

  EventCallback<NormalEvent>? horizontalDragStart;
  EventCallback<NormalEvent>? horizontalDragMove;
  EventCallback<VelocityEvent>? horizontalDragEnd;
  VoidCallback? horizontalDragCancel;

  EventCallback<NormalEvent>? scaleStart;
  EventCallback<ScaleEvent>? scaleUpdate;
  EventCallback<VelocityEvent>? scaleEnd;
  VoidCallback? scaleCancel;

  Fun1<Offset, bool>? edgeFun;

  bool isInArea(Offset globalOffset);

  void clear() {
    click = null;
    clickDown = null;
    clickUp = null;
    clickCancel = null;

    doubleClick = null;
    doubleClickDown = null;
    doubleClickUp = null;
    doubleClickCancel = null;

    longPressStart = null;
    longPressMove = null;

    longPressEnd = null;
    longPressCancel = null;

    hoverStart = null;
    hoverMove = null;
    hoverEnd = null;

    verticalDragStart = null;
    verticalDragMove = null;
    verticalDragEnd = null;

    horizontalDragStart = null;
    horizontalDragMove = null;
    horizontalDragEnd = null;

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


  @override
  bool isInArea(Offset globalOffset) {
    if (edgeFun != null) {
      return edgeFun!.call(globalOffset);
    }
    return globalOffset.inSector(innerRadius, outerRadius, startAngle, sweepAngle);
  }
}
