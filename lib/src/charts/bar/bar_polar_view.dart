import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/bar/helper/polar_helper.dart';

import '../common/stack/polar/polar_view.dart';

class BarPolarView extends PolarView<StackItemData, BarGroupData, BarSeries, BarPolarHelper> {
  BarPolarView(super.context,super.series);

  @override
  BarPolarHelper buildLayoutHelper(BarPolarHelper? oldHelper) {
    oldHelper?.dispose();
    return BarPolarHelper(context,this, series);
  }
}
