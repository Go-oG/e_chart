import '../core/view.dart';
import '../model/string_number.dart';
import 'coord.dart';
import 'coord_config.dart';

abstract class RectCoord<T extends RectCoordConfig> extends Coord<T> {
  RectCoord(super.props) {
    layoutParams = props.toLayoutParams();
  }
}

/// 一个矩形范围的坐标系
abstract class RectCoordConfig extends CoordConfig {
  SNumber leftMargin;
  SNumber topMargin;
  SNumber rightMargin;
  SNumber bottomMargin;
  SNumber? width;
  SNumber? height;

  RectCoordConfig({
    this.leftMargin = const SNumber.number(0),
    this.topMargin = const SNumber.number(0),
    this.rightMargin = const SNumber.number(0),
    this.bottomMargin = const SNumber.number(0),
    this.width,
    this.height,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
  });

  LayoutParams toLayoutParams() {
    return LayoutParams(width ?? const SNumber(LayoutParams.matchParent, false), height ?? const SNumber(LayoutParams.matchParent, false),
        leftMargin: leftMargin, topMargin: topMargin, rightMargin: rightMargin, bottomMargin: rightMargin);
  }
}
