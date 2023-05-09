import 'package:flutter/material.dart';
import 'package:xchart/src/style/area_style.dart';

import '../../../action/user_action.dart';
import '../bar_series.dart';

/// 不可再分的最小绘制单元，
class SingleNode {
  final BarSeries series;
  final GroupData groupData;
  final SingleData data;

  ///实现动画相关的
  late SingleProps cur;

  late SingleProps start;

  late SingleProps end;

  late num up;
  late num down;

  SingleNode(this.series, this.groupData, this.data) {
    cur = SingleProps();
    start = SingleProps();
    end = SingleProps();
    up = data.up;
    down = data.down;
  }

  void draw(Canvas canvas, Paint paint) {
    AreaStyle? style = series.styleFun.call(data, groupData, cur.convertAction());
    if (style == null) {
      return;
    }
    style.drawRect(canvas, paint,cur.rect);
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SingleNode) {
      return other.data == data;
    }
    return false;
  }
}

class SingleProps {
  Rect rect = Rect.zero;
  bool hover = false;
  bool select = false;

  SingleProps();

  UserAction? convertAction() {
    return null;
  }
}
