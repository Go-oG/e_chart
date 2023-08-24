import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ParallelNode extends DataNode<List<Offset?>,ParallelGroup> {

  Path? path;

  ParallelNode(super.data,super.dataIndex,super.groupIndex,super.attr);

}
