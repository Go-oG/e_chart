import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';

import '../../core/view.dart';
import '../../core/view_group.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';

class FlexLayout extends ViewGroup {
  Direction direction;
  VerticalDirection crossDirection;
  Align2 align;

  FlexLayout({
    this.direction = Direction.horizontal,
    this.crossDirection = VerticalDirection.down,
    this.align = Align2.start,
  });

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    for (var c in children) {
      c.measure(parentWidth, parentHeight);
    }
    List<List<View>> vl = splitView(parentWidth, parentHeight);
    num w = 0;
    num h = 0;
    for (var list in vl) {
      num maxW = 0;
      num maxH = 0;
      if (direction == Axis.vertical) {
        for (var c in list) {
          maxW = max([c.width, maxW]);
          maxH += c.height;
        }
      } else {
        for (var c in list) {
          maxH = max([c.height, maxH]);
          maxW += c.width;
        }
      }
      if (direction == Axis.vertical) {
        w += maxW;
        h = max([maxH, h]);
      } else {
        h += maxH;
        w = max([maxW, w]);
      }
    }
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    List<List<View>> vl = splitView(width, height);
    double l = 0;
    double y = direction == Axis.vertical ? height : 0;
    for (var list in vl) {
      num maxW = maxBy<View>(list, (p0) => p0.width).width;
      num maxH = maxBy<View>(list, (p0) => p0.height).height;

      for (var c in list) {
        if (crossDirection == VerticalDirection.down) {
          if (align == Align2.start) {
            c.layout(l, y, l + c.width, y + c.height);
          } else if (align == Align2.end) {
            c.layout(l, y + maxH - c.height, l + c.width, y + maxH);
          } else {
            //center
            double tt = y + (maxH - c.height) / 2;
            c.layout(l, tt, l + c.width, tt + c.height);
          }
        } else {
          if (align == Align2.start) {
            c.layout(l, y - maxH, l + c.width, y - maxH + c.height);
          } else if (align == Align2.end) {
            c.layout(l, y - c.height, l + c.width, y);
          } else {
            double tt = y - (maxH - c.height) / 2;
            c.layout(l, tt - c.height, l + c.width, tt);
          }
        }
        if (direction == Axis.vertical) {
          if (crossDirection == VerticalDirection.down) {
            y += c.height;
          } else {
            y -= c.height;
          }
        } else {
          l += c.width;
        }
      }

      if (direction == Axis.vertical) {
        l += maxW;
        y = crossDirection == VerticalDirection.up ? height : 0;
      } else {
        l = 0;
        y = crossDirection == VerticalDirection.up ? (y - maxH) : (y + maxH);
      }
    }
  }

  List<List<View>> splitView(double pw, double ph) {
    num w = 0;
    num h = 0;
    List<List<View>> vl = [];
    List<View> tmpList = [];
    for (var c in children) {
      if (direction == Axis.vertical) {
        if (h < ph) {
          if ((c.height + h) >= ph) {
            vl.add(tmpList);
            tmpList = [c];
            h = c.height;
          } else {
            tmpList.add(c);
            h += c.height;
          }
        }
      } else {
        if (w < pw) {
          if ((c.width + w) >= pw) {
            w = pw;
            vl.add(tmpList);
            tmpList = [c];
            w = c.width;
          } else {
            tmpList.add(c);
            w += c.width;
          }
        }
      }
    }
    if (tmpList.isNotEmpty) {
      vl.add(tmpList);
      tmpList = [];
    }
    return vl;
  }
}
