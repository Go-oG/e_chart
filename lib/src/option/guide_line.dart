import 'package:flutter/material.dart';

import 'style/line_style.dart';

///引导线
class GuideLine {
  bool show;
  num length;
  LineStyle style;
  List<num> gap; //线和文字之间的距离

  GuideLine({
    this.show = true,
    this.length = 16,
    this.style = const LineStyle(color: Colors.black),
    this.gap = const [4, 0],
  });
}
