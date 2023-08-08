import 'package:e_chart/e_chart.dart';

class DataZoomEvent extends ChartEvent {
  final DataZoomAction action;

  DataZoomEvent(this.action);
}
