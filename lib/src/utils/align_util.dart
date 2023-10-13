import 'package:flutter/cupertino.dart';

import '../ext/offset_ext.dart';

///给定角度值返回其文本绘制对齐模式
Alignment toAlignment(num angle, [bool inner = false]) {
  Offset offset = circlePoint(1, angle);
  if (!inner) {
    return Alignment(-offset.dx, -offset.dy);
  }
  return Alignment(offset.dx, offset.dy);
}

///将一个对齐量转为内部对齐值
///一般用于在Rect 内部绘制文字对齐时使用
Alignment toInnerAlign(Alignment align) {
  if (align.x > 0) {
    if (align.y > 0) {
      return Alignment.bottomRight;
    }
    if (align.y < 0) {
      return Alignment.topRight;
    }
    return Alignment.centerRight;
  }
  if (align.x < 0) {
    if (align.y > 0) {
      return Alignment.bottomLeft;
    }
    if (align.y < 0) {
      return Alignment.topLeft;
    }
    return Alignment.centerLeft;
  } else {
    if (align.y > 0) {
      return Alignment.bottomCenter;
    }
    if (align.y < 0) {
      return Alignment.topCenter;
    }
  }
  return Alignment.center;
}

