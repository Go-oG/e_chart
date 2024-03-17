import 'package:e_chart/e_chart.dart';
import 'helper/bar_grid_helper.dart';

class BarGridView extends GridView<StackItemData, BarGroupData, BarSeries, BarGridHelper> {
  BarGridView(super.context,super.series);

  @override
  BarGridHelper buildLayoutHelper(BarGridHelper? oldHelper) {
    oldHelper?.dispose();
    return BarGridHelper(context,this, series);
  }
}
