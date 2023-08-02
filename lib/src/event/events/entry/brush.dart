import 'package:e_chart/e_chart.dart';

import '../chart_event.dart';

class BrushEvent extends ChartEvent {
  final List<BrushActionData> action;

  BrushEvent(this.action);
}

class BrushEndEvent extends ChartEvent {
  final List<BrushActionData> action;

  BrushEndEvent(this.action);
}

class BrushSelectedEvent extends ChartEvent {
  final List<BrushSelectData> data;

  BrushSelectedEvent(this.data);
}

class BrushSelectData {
  //TODO
}
