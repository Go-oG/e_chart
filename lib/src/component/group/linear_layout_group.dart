import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class LinearLayout extends ChartViewGroup {
  Direction direction;

  LinearLayout({this.direction = Direction.vertical});

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    var lp = layoutParams;
    var padding = lp.padding;
    double w = 0, h = 0;
    if (lp.width.isNormal) {
      w = lp.width.convert(parentWidth) - padding.horizontal;
    } else {
      w = parentWidth - padding.horizontal;
    }

    if (lp.height.isNormal) {
      h = lp.height.convert(parentHeight) - padding.vertical;
    } else {
      h = parentHeight - padding.vertical;
    }

    for (var c in children) {
      c.measure(w, h);
    }

    w = 0;
    h = 0;
    for (var c in children) {
      if (direction == Direction.vertical) {
        w = max([w, c.width]).toDouble();
        h += c.height;
      } else {
        h = max([h, c.height]).toDouble();
        w += c.width;
      }
    }

    w += padding.horizontal;
    h += padding.vertical;

    double dw = 0;
    double dh = 0;
    if (lp.width.isMatch) {
      dw = parentWidth;
    } else if (lp.width.isWrap) {
      dw = w.toDouble();
    } else {
      dw = lp.width.convert(parentWidth);
    }
    if (lp.height.isMatch) {
      dh = parentHeight;
    } else if (lp.height.isWrap) {
      dh = h.toDouble();
    } else {
      dh = lp.height.convert(parentHeight);
    }
    return Size(dw, dh);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    var lp = layoutParams.padding;
    double offset = direction == Direction.vertical ? lp.top : lp.left;
    for (var c in children) {
      var cm = c.layoutParams.margin;
      if (direction == Direction.vertical) {
        c.layout(
          lp.left + cm.left,
          offset + cm.top,
          lp.left + cm.left + c.width,
          offset + cm.top + c.height,
        );
        offset += c.height + cm.top;
      } else {
        c.layout(
          offset + cm.left,
          lp.top + cm.top,
          offset + cm.left + c.width,
          lp.top + cm.top + c.height,
        );
        offset += c.width + cm.left;
      }
    }
  }
}
