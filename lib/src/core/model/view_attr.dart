import 'dart:ui';

import '../../model/chart_edgeinset.dart';
import 'layout_params.dart';

mixin ViewAttr {
  ///存储当前节点的布局属性
  late LayoutParams layoutParams = const LayoutParams.matchAll();

  ///存储当前视图在父视图中的位置属性
  Rect boxBound = Rect.zero;

  ///记录旧的边界位置，可用于动画相关的计算
  Rect oldBound = Rect.zero;

  ///记录其全局位置
  Rect globalBound = Rect.zero;

  ChartEdgeInset margin = ChartEdgeInset();

  ChartEdgeInset padding = ChartEdgeInset();

  Offset toLocal(Offset global) {
    return Offset(global.dx - globalBound.left, global.dy - globalBound.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + globalBound.left, local.dy + globalBound.top);
  }

  double get width => boxBound.width;

  double get height => boxBound.height;

  double get left => boxBound.left;

  double get top => boxBound.top;

  double get right => boxBound.right;

  double get bottom => boxBound.bottom;

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  Rect get selfBoxBound => Rect.fromLTWH(0, 0, width, height);

  Size get size => Size(width, height);

  double translationX = 0;

  double translationY = 0;

  Offset get translation => Offset(translationX, translationY);

  double scaleX = 1;

  double scaleY = 1;

  Offset get scale => Offset(scaleX, scaleY);
}
