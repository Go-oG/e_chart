import 'package:flutter/gestures.dart';

class MotionEvent {}

class NormalEvent extends MotionEvent {
  final Offset globalPosition;

  NormalEvent(this.globalPosition);
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

class ScaleEvent extends MotionEvent {
  final Offset focalPoint;
  final double scale;
  final double rotation;

  ScaleEvent(this.focalPoint, this.scale, this.rotation);
}
