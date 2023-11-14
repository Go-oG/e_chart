import 'dart:ui';

Size lerpSize(Size a, Size b, double t) {
  if (a == b) {
    return b;
  }
  if (t == 0) {
    return a;
  }
  if (t == 1) {
    return b;
  }
  return Size.lerp(a, b, t)!;
}

Offset lerpOffset(Offset a, Offset b, double t) {
  if (a == b) {
    return b;
  }
  if (t == 0) {
    return a;
  }
  if (t == 1) {
    return b;
  }
  return Offset.lerp(a, b, t)!;
}

Rect lerpRect(Rect a, Rect b, double t) {
  if (a == b) {
    return b;
  }
  if (t == 0) {
    return a;
  }
  if (t == 1) {
    return b;
  }
  return Rect.lerp(a, b, t)!;
}

int lerpInt(int s, int e, num t) {
  if (s == e || (s.isNaN && e.isNaN)) {
    return s;
  }
  return (s + (e - s) * t).round();
}

double lerpNum(num s, num e, num t) {
  if (s == e || (s.isNaN && e.isNaN)) {
    return s.toDouble();
  }
  return s.toDouble() + (e - s) * t;
}
