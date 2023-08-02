import 'package:e_chart/e_chart.dart';

class LegendSelectAction extends ChartAction {
  final LegendItem legend;

  LegendSelectAction(this.legend, {super.fromUser});
}

class LegendUnSelectAction extends ChartAction {
  final LegendItem legend;
  LegendUnSelectAction(this.legend, {super.fromUser});
}

class LegendToggleSelectAction extends ChartAction {
  final Legend legend;
  LegendToggleSelectAction(this.legend, {super.fromUser});
}

class LegendScrollAction extends ChartAction {
  final int scrollIndex;

  LegendScrollAction(this.scrollIndex,{super.fromUser});
}
