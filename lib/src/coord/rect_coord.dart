import '../core/view.dart';
import '../model/string_number.dart';
import 'coord.dart';

/// 一个矩形范围的坐标系
abstract class RectCoordinate extends Coordinate {
  final SNumber leftMargin;
  final SNumber topMargin;
  final SNumber rightMargin;
  final SNumber bottomMargin;
  final SNumber? width;
  final SNumber? height;

  const RectCoordinate({
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
