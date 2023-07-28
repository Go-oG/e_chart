import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/index.dart';
import '../../functions.dart';
import '../../model/enums/direction.dart';
import '../../model/range.dart';
import '../../style/index.dart';
import '../coord.dart';

///日历坐标系
class Calendar extends Coord {
  Pair<DateTime> range;
  bool sunFirst;

  //日历每格框的大小，可设置单值或数组
  //第一个元素是宽 第二个元素是高。
  //支持设置自适应(为空则为自适应)
  //默认为高宽均为20
  List<num?> cellSize;
  Direction direction;
  SplitLine? splitLine;
  Fun2<int, LabelStyle>? weekStyleFun;
  Fun2<DateTime, LabelStyle>? dayStyleFun;
  LineStyle? borderStyle;
  LineStyle? gridLineStyle;

  Calendar({
    required this.range,
    this.sunFirst = true,
    this.cellSize = const [20, 20],
    this.direction = Direction.horizontal,
    this.splitLine,
    this.borderStyle,
    this.gridLineStyle,
    this.weekStyleFun,
    this.dayStyleFun,
    super.padding,
    super.margin,
    super.width,
    super.height,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
  });

  @override
  CoordSystem get coordSystem => CoordSystem.calendar;
}
