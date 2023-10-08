import 'package:e_chart/e_chart.dart';
import 'pie_helper.dart';
import 'pie_node.dart';

/// 饼图
class PieView extends SeriesView<PieSeries, PieHelper> {
  PieView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    List<PieNode> nodeList = layoutHelper.nodeList;
    each(nodeList, (node, i) {
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  PieHelper buildLayoutHelper(var oldHelper) {
    if(oldHelper!=null){
      oldHelper.context=context;
      oldHelper.view=this;
      oldHelper.series=series;
      return oldHelper;
    }
    return PieHelper(context, this, series);
  }
}
