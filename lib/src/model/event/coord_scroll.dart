import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CoordScroll {
  final String coordId;
  final CoordType coord;
  final Offset scroll;

  const CoordScroll(this.coordId, this.coord, this.scroll);
}
