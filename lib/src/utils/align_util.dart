import 'package:flutter/cupertino.dart';

import '../ext/offset_ext.dart';

///给定角度值返回其文本绘制对齐模式
Alignment toAlignment(num angle, [bool inner = false]) {
  Offset offset=circlePoint(1, angle);
  if(!inner){
    return Alignment(-offset.dx, -offset.dy);
  }
  return Alignment(offset.dx, offset.dy);

}
