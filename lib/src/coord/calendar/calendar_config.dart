
import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/axis/split_line.dart';
import '../../functions.dart';
import '../../model/enums/direction.dart';
import '../../model/range.dart';
import '../../style/label.dart';
import '../rect_coord.dart';

///日历坐标系
class CalendarConfig extends RectCoordConfig {
  final Pair<DateTime> range;
  final bool sunFirst;

  //日历每格框的大小，可设置单值或数组
  //第一个元素是宽 第二个元素是高。
  //支持设置自适应(为空则为自适应)
  //默认为高宽均为20
  final List<num?> cellSize;
  final Direction direction;
  final SplitLine splitLine;
  final StyleFun<int, LabelStyle>? weekStyleFun;
  final StyleFun<DateTime, LabelStyle>? dayStyleFun;

  CalendarConfig({
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    required this.range,
    this.sunFirst = true,
    this.cellSize = const [20, 20],
    this.direction = Direction.horizontal,
    this.splitLine = const SplitLine(),
    this.weekStyleFun,
    this.dayStyleFun,
  });

  @override
  CoordSystem get coordSystem => CoordSystem.calendar;
}
