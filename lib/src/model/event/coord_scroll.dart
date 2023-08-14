import 'package:e_chart/e_chart.dart';

class CoordScroll {
  final String coordId;
  final CoordType coord;
  double dx;
  double dy;

  CoordScroll(this.coordId, this.coord, this.dx, this.dy);
}
