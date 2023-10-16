import 'package:e_chart/e_chart.dart';

///坐标系相关的事件
//================
///坐标系布局发生了变化(Children需要进行重新布局)
///一般情况是缩放或者数据发生了改变，导致坐标轴更新
class CoordLayoutChangeEvent extends ChartEvent {
  final String coordViewId;
  final String coordId;
  final CoordType coord;

  const CoordLayoutChangeEvent(this.coordViewId,this.coordId, this.coord);

  @override
  EventType get eventType => EventType.coordLayoutChange;
}

class CoordScrollEvent extends ChartEvent {
  final String coordViewId;
  final String coordId;
  final CoordType coord;

  CoordScrollEvent(this.coordViewId,this.coordId, this.coord);

  double scrollX = 0;
  double scrollY = 0;

  @override
  EventType get eventType => EventType.coordScroll;

  @override
  String toString() {
    return "id:$coordId coord:$coord TX:${scrollX.toStringAsFixed(2)} TY:${scrollY.toStringAsFixed(2)}";
  }
}
