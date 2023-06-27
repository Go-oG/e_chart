import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ParallelNode with ViewStateProvider {
  final ParallelGroup data;

  List<Offset?> offsetList = [];
  Path? path;

  ParallelNode(this.data);

  void update(List<Offset?> list){
    offsetList=list;
  }

}
