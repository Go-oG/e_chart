import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../model/enums/direction.dart';
import '../../model/string_number.dart';
import '../coord_config.dart';
import 'parallel_axis.dart';

class ParallelConfig extends CoordConfig {
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
    this.expandable = false,
    this.expandStartIndex = 0,
    this.expandCount = 0,
    this.expandWidth = 30,
    this.axisList = const [],
    this.leftPadding = const SNumber.percent(5),
    this.topPadding = const SNumber.percent(5),
    this.rightPadding = const SNumber.percent(5),
    this.bottomPadding = const SNumber.percent(2),
    super.width,
    super.height,
    super.id,
    super.show,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.margin,
    super.padding,
  });

  @override
  CoordSystem get coordSystem => CoordSystem.parallel;
}
