import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import '../../core/model/models.dart';

class LinearLayout extends ChartViewGroup {
  Direction direction;

  LinearLayout(super.context, {this.direction = Direction.vertical});

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    var parentWidth = widthSpec.size;
    var parentHeight = heightSpec.size;

    if (layoutParams.width.isNormal) {
      parentWidth = layoutParams.width.convert(parentWidth);
    }
    if (layoutParams.height.isNormal) {
      parentHeight = layoutParams.height.convert(parentHeight);
    }

    padding.left = layoutParams.getLeftPadding(parentWidth);
    padding.right = layoutParams.getRightPadding(parentWidth);
    padding.top = layoutParams.getTopPadding(parentHeight);
    padding.bottom = layoutParams.getBottomPadding(parentHeight);

    var lp = layoutParams;
    double w = parentWidth - padding.horizontal;
    double h = parentHeight - padding.vertical;

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
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    double offset = direction == Direction.vertical ? padding.top : padding.left;
    for (var c in children) {
      var cm = c.margin;
      if (direction == Direction.vertical) {
        c.layout(
          padding.left + cm.left,
          offset + cm.top,
          padding.left + cm.left + c.width,
          offset + cm.top + c.height,
        );
        offset += c.height + cm.top;
      } else {
        c.layout(
          offset + cm.left,
          padding.top + cm.top,
          offset + cm.left + c.width,
          padding.top + cm.top + c.height,
        );
        offset += c.width + cm.left;
      }
    }
  }
}
