import 'package:e_chart/e_chart.dart';
import 'radar_helper.dart';

/// 雷达图
class RadarView extends SeriesView<RadarSeries, RadarHelper> implements RadarChild {
  RadarView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var nodeList = layoutHelper.dataList;
    each(nodeList, (group, i) {
      group.onDraw(canvas, mPaint);
    });
  }

  @override
  List<num> getRadarExtreme(int dim) {
    List<num> resultList = [];
    for (var group in series.data) {
      if (group.value.length > dim) {
        resultList.add(group.value[dim].value);
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
