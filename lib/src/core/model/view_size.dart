import 'dart:ui';

import '../../model/chart_edgeinset.dart';
import 'layout_params.dart';

mixin ViewSize {
  ///存储当前节点的布局方式
  LayoutParams layoutParams = const LayoutParams.matchAll();

  ///存储当前视图在父视图中的位置属性
  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);

  ///记录旧的边界位置，可用于动画相关的计算
  Rect oldBound = const Rect.fromLTRB(0, 0, 0, 0);

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

  double get width => boundRect.width;

  double get height => boundRect.height;

  double get left => boundRect.left;

  double get top => boundRect.top;

  double get right => boundRect.right;

  double get bottom => boundRect.bottom;

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  Rect get boxBound => boundRect;

  Rect get selfBoxBound => Rect.fromLTWH(0, 0, width, height);

  Size get size => Size(width, height);

  double translationX = 0;
  double translationY = 0;

  Offset get translation => Offset(translationX, translationY);

  double scaleX = 1;
  double scaleY = 1;

  Offset get scale => Offset(scaleX, scaleY);

}
