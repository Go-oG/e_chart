import 'package:flutter/gestures.dart';

class MotionEvent {
}

class NormalEvent extends MotionEvent {
  final Offset globalPosition;
  final Offset? delta;

  NormalEvent(this.globalPosition, this.delta);
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

class ScaleEvent extends NormalEvent {
  final double scale;
  final double horizontalScale;
  final double verticalScale;
  final double rotation;

  ScaleEvent(
    this.scale,
    this.horizontalScale,
    this.verticalScale,
    this.rotation,
    super.globalPosition,
    super.delta,
  );
}

class VelocityEvent extends MotionEvent {
  final Velocity velocity;
  final int pointCount;

  VelocityEvent(this.velocity, this.pointCount);
}
