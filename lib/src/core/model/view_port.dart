import 'dart:ui';

///可视区域的表示
class ViewPort {
  double width = 0;
  double height = 0;

  double contentWidth = 0;
  double contentHeight = 0;

  double scrollX = 0;
  double scrollY = 0;

  ViewPort(this.width, this.height, this.contentWidth, this.contentHeight);

  ViewPort.zero();

  Offset scroll(Offset scroll) {
    return scrollTo(scroll.dx, scroll.dy);
  }

  Offset scrollTo(double dx, double dy) {
    if (dx != 0) {
      var maxX = maxScrollX;
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
      var maxY = maxScrollY;
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

  Offset get translation => Offset(scrollX, scrollY);

  double get maxScrollX {
    if (contentWidth <= width) {
      return 0;
    }
    return (contentWidth - width).toDouble();
  }

  double get maxScrollY {
    if (contentHeight <= height) {
      return 0;
    }
    return (contentHeight - height).toDouble();
  }
}
