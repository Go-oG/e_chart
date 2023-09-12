import 'package:flutter/gestures.dart';

class MotionEvent {
  const MotionEvent();
}

class TapEvent extends MotionEvent {
  final int pointer;
  final Offset localPos;
  final Offset position;
  const TapEvent(this.localPos, this.position, this.pointer);

  static from(PointerEvent event) {
    return TapEvent(event.localPosition, event.position, event.pointer);
  }

  Offset get globalPosition=>localPos;
}

class ScaleEvent extends MotionEvent {
  final Offset focalPoint;
  final double scale;
  final double rotation;

  const ScaleEvent(this.focalPoint, this.scale, this.rotation);
}

class LongPressMoveEvent extends MotionEvent {
  final Offset globalPosition;
  final Offset localOffsetFromOrigin;
  final Offset offsetFromOrigin;

  LongPressMoveEvent(
    this.globalPosition,
    this.localOffsetFromOrigin,
    this.offsetFromOrigin,
  );
}

class MoveEvent extends TapEvent {
  final Offset localDelta;
  final Offset delta;

  const MoveEvent(
    Offset localPos,
    Offset position,
    int pointer, {
    this.localDelta = const Offset(0, 0),
    this.delta = const Offset(0, 0),
  }) : super(localPos, position, pointer);
}

class ScrollEvent {
  final int pointer;
  final Offset localPos;
  final Offset position;
  final Offset scrollDelta;

  const ScrollEvent(this.pointer, this.localPos, this.position, this.scrollDelta);
}
