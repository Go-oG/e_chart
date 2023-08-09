import 'package:e_chart/e_chart.dart';
import 'helper/bar_grid_helper.dart';

class BarGridView extends GridView<StackItemData, BarGroupData, BarSeries, BarGridHelper> {
  BarGridView(super.series);

  @override
  BarGridHelper buildLayoutHelper() {
    return BarGridHelper(context, series);
  }
}
