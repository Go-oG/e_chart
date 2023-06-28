import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../model/enums/direction.dart';
import '../../model/string_number.dart';
import '../rect_coord.dart';
import 'parallel_axis.dart';

class ParallelConfig extends RectCoordConfig {
  Direction direction;
  bool expandable;
  int expandStartIndex;
  int expandCount;
  num expandWidth;

  List<ParallelAxis> axisList;
  SNumber leftPadding;
  SNumber topPadding;
  SNumber rightPadding;
  SNumber bottomPadding;

  ParallelConfig({
    this.direction = Direction.horizontal,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.width,
    super.height,
    this.expandable = false,
    this.expandStartIndex = 0,
    this.expandCount = 0,
    this.expandWidth = 30,
    this.axisList = const [],
    this.leftPadding = const SNumber.percent(5),
    this.topPadding = const SNumber.percent(5),
    this.rightPadding = const SNumber.percent(5),
    this.bottomPadding = const SNumber.percent(2),
    super.id,
    super.show,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
  });

  @override
  CoordSystem get coordSystem => CoordSystem.parallel;
}
