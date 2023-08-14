import 'dart:ui';

Offset adjustScrollOffset(Offset scroll, Offset maxScroll) {
  var sx = scroll.dx;
  var sy = scroll.dy;
  if (sx.abs() > maxScroll.dx) {
    sx = -maxScroll.dx;
  }
  if (sx > 0) {
    sx = 0;
  }
  if (sy.abs() > maxScroll.dy) {
    sy = maxScroll.dy;
  }
  if (sy < 0) {
    sy = 0;
  }
  return Offset(sx, sy);
}

Offset adjustScrollOffset2(double curX, double curY, double dx, double dy, double maxX, double maxY) {
  var sx = curX + dx;
  var sy = curY + dy;
  if (sx.abs() > maxX) {
    sx = -maxX;
  }
  if (sx > 0) {
    sx = 0;
  }
  if (sy.abs() > maxY) {
    sy = maxY;
  }
  if (sy < 0) {
    sy = 0;
  }
  return Offset(sx, sy);
}
