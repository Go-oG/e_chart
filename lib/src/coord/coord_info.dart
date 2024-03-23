import 'package:e_chart/e_chart.dart';

class CoordInfo {
  final CoordType type;
  final int index;

  const CoordInfo(this.type, this.index) :assert(index >= 0);

}
