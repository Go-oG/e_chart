import 'package:e_chart/e_chart.dart';
import 'radar_helper.dart';

/// 雷达图
class RadarView extends SeriesView<RadarSeries, RadarHelper> implements RadarChild {
  RadarView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var nodeList = layoutHelper.groupNodeList;
    each(nodeList, (group, i) {
      group.onDraw(canvas, mPaint);
    });
  }

  @override
  List<num> dataSet(int dim) {
    List<num> resultList = [];
    for (var group in series.data) {
      if (group.data.length > dim) {
        resultList.add(group.data[dim].value);
      }
    }
    return resultList;
  }

  @override
  int get radarIndex => series.radarIndex;

  @override
  RadarHelper buildLayoutHelper(var oldHelper) {
    if(oldHelper!=null){
      oldHelper.context=context;
      oldHelper.view=this;
      oldHelper.series=series;
      return oldHelper;
    }
    return RadarHelper(context, this, series);
  }
}
