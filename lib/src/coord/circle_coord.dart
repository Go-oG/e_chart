import '../model/string_number.dart';
import 'coord.dart';

/// 一个圆形范围的坐标系
abstract class CircleCoordinate extends Coordinate {
  final List<SNumber> center;
  final SNumber radius;

  const CircleCoordinate({
    this.radius = const SNumber.percent(50),
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.id,
    super.show,
  });
}
