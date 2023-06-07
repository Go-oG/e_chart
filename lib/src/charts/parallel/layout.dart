import 'package:flutter/material.dart';
import '../../coord/parallel/parallel_coord.dart';
import '../../shape/line.dart';
import '../../style/line_style.dart';
import 'parallel_chart.dart';
import 'parallel_series.dart';

class LayoutHelper {
  late final ParallelSeries series;
  final ParallelView view;

  LayoutHelper(this.view) {
    series = view.series;
  }

  List<ParallelDataLine> layout(double left, double top, double width, double height) {
    List<ParallelDataLine> resultList = [];
    ParallelCoord layout = view.context.findParallelCoord(series.parallelIndex);
    for (var element in series.data) {
      List<Offset> ol = [];
      for (int i = 0; i < element.data.length; i++) {
        var data = element.data[i];
        Offset? offset = layout.dataToPoint(i,data);
        if (offset == null) {
          continue;
        }
        ol.add(offset);
      }
      ParallelDataLine data = ParallelDataLine(element, ol, series.styleFun.call(element, null));
      resultList.add(data);
    }
    return resultList;
  }
}

//数据线
class ParallelDataLine {
  final ParallelGroup group;
  final List<Offset> offsetList;
  Path? path;
  LineStyle? style;

  ParallelDataLine(this.group, this.offsetList, this.style) {
    if (style != null && offsetList.length >= 2) {
      Line line=Line(offsetList,dashList: style!.dash,smoothRatio: style!.smooth ? 0.2 : null);
      path =line.toPath(false);
    }
  }
}
