import 'package:e_chart/src/coord/index.dart';
import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../core/context.dart';
import '../../model/enums/direction.dart';

class Parallel extends Coord {
  Direction direction;
  bool expandable;
  int expandStartIndex;
  int expandCount;
  num expandWidth;

  List<ParallelAxis> axisList;

  Parallel({
    this.direction = Direction.horizontal,
    this.expandable = false,
    this.expandStartIndex = 0,
    this.expandCount = 0,
    this.expandWidth = 30,
    this.axisList = const [],
    super.id,
    super.show,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
  });

  @override
  CoordType get coordSystem => CoordType.parallel;

  @override
  CoordLayout<Coord>? toCoord(Context context) {
    return ParallelCoordImpl(context, this);
  }
}
