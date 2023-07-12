import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class ChartLayout<S extends ChartSeries, T> extends ChartNotifier<Command> {
  ChartLayout({bool equalsObject = false}) : super(Command.none, equalsObject);

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  late Context context;
  late S series;

  Rect rect = Rect.zero;
  late T data;

  void doMeasure(double parentWidth,double parentHeight){}

  void doLayout(Context context, S series, T data, Rect rect, LayoutAnimatorType type) {
    this.context = context;
    this.series = series;
    this.rect = rect;
    onLayout(data, type);
  }

  void onLayout(T data, LayoutAnimatorType type);

  void stopLayout(){}

  double get width => rect.width;

  double get height => rect.height;

}

enum LayoutAnimatorType { none, layout, update }
