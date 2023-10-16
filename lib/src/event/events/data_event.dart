import 'package:e_chart/e_chart.dart';

///数据发生改变后的事件
class DataStatusChangeEvent extends ChartEvent {
  final dynamic data;
  final Set<ViewState> states;

  const DataStatusChangeEvent(this.data,this.states);

  @override
  EventType get eventType => EventType.dataStatusChanged;
}
