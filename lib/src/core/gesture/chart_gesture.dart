import 'dart:ui';

import '../../functions.dart';
import 'gesture_event.dart';

typedef EventCallback<T> = void Function(T);

abstract class ChartGesture {
  EventCallback<TapEvent>? click;
  EventCallback<TapEvent>? doubleClick;
  EventCallback<TapEvent>? longPressStart;
  EventCallback<MoveEvent>? longPressMove;
  VoidCallback? longPressEnd;
  EventCallback<TapEvent>? hoverStart;
  EventCallback<TapEvent>? hoverMove;
  EventCallback<TapEvent>? hoverEnd;
  EventCallback<TapEvent>? dragStart;
  EventCallback<TapEvent>? dragMove;
  VoidCallback? dragEnd;
  EventCallback<TapEvent>? scaleStart;
  EventCallback<ScaleEvent>? scaleUpdate;
  VoidCallback? scaleEnd;
  Fun2<Offset, bool>? edgeFun;

  bool contains(Offset globalOffset);

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
  bool contains(Offset globalOffset) {
    if (edgeFun != null) {
      return edgeFun!.call(globalOffset);
    }
    return rect.contains(globalOffset);
  }
}

class CallGesture extends ChartGesture {
  Fun2<Offset, bool>? hintCall;

  CallGesture(this.hintCall);

  @override
  bool contains(Offset globalOffset) {
    return hintCall?.call(globalOffset) ?? false;
  }

  @override
  void clear() {
    hintCall = null;
    super.clear();
  }
}
