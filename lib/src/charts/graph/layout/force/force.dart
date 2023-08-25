import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

abstract class Force {
  num width = 0;
  num height = 0;

  @mustCallSuper
  void initialize(Context context, Graph graph, LCG lcg, num width, num height) {
    this.width = width;
    this.height = height;
  }

  void force(double alpha);

  void onFinish() {}
}
