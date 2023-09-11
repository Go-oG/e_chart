import 'dart:ui';

///帮助计算一个可见区域内能够最大滚动的偏移量
class ViewPort {
  num width = 0;
  num height = 0;
  num contentWidth = 0;
  num contentHeight = 0;
  double scrollX = 0;
  double scrollY = 0;

  ViewPort(this.width, this.height, this.contentWidth, this.contentHeight);

  ViewPort.zero();

  Offset scroll(Offset scroll) {
    return scroll2(scroll.dx, scroll.dy);
  }

  Offset scroll2(double dx, double dy) {
    if (dx != 0) {
      var maxX = getMaxScrollX();
      var sx = scrollX + dx;
      if (sx.abs() > maxX) {
        sx = -maxX;
      }
      if (sx > 0) {
        sx = 0;
      }
      scrollX = sx;
    }
    if (dy != 0) {
      var sy = scrollY + dy;
      var maxY = getMaxScrollY();
      if (sy.abs() > maxY) {
        sy = maxY;
      }
      if (sy < 0) {
        sy = 0;
      }
      scrollY = sy;
    }
    return Offset(scrollX.toDouble(), scrollY.toDouble());
  }

  Offset getTranslation() {
    return Offset(scrollX,scrollY);
  }

  double getMaxScrollX() {
    if (contentWidth <= width) {
      return 0;
    }
    return (contentWidth - width).toDouble();
  }

  double getMaxScrollY() {
    if (contentHeight <= height) {
      return 0;
    }
    return (contentHeight - height).toDouble();
  }
}
