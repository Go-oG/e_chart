import '../core/view.dart';
import '../model/string_number.dart';
import 'coord.dart';
import 'coord_config.dart';


abstract class RectCoord<T extends RectCoordConfig> extends Coord {
  final T props;

  RectCoord(this.props){
    layoutParams=props.toLayoutParams();
  }
}

/// 一个矩形范围的坐标系
abstract class RectCoordConfig extends CoordConfig {
  final SNumber leftMargin;
  final SNumber topMargin;
  final SNumber rightMargin;
  final SNumber bottomMargin;
  final SNumber? width;
  final SNumber? height;

  const RectCoordConfig({
    this.leftMargin = const SNumber.number(0),
    this.topMargin = const SNumber.number(0),
    this.rightMargin = const SNumber.number(0),
    this.bottomMargin = const SNumber.number(0),
    this.width,
    this.height,
    super.id,
    super.show,
  });

  LayoutParams toLayoutParams() {
    return LayoutParams(
        width ?? const SNumber(LayoutParams.matchParent, false),
        height ?? const SNumber(LayoutParams.matchParent, false),
        leftMargin: leftMargin,
        topMargin: topMargin,
        rightMargin: rightMargin,
        bottomMargin: rightMargin
    );
  }

}
