import '../../model/enums/coordinate.dart';
import '../coord_impl.dart';
import '../coord.dart';

///用于包装child
class SingleCoordImpl extends CoordLayout {
  SingleCoordImpl() : super(SingleConfig());

  @override
  double getMaxXScroll() {
    return 0;
  }

  @override
  double getMaxYScroll() {
    return 0;
  }
}

class SingleConfig extends Coord {
  SingleConfig({
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
  });

  @override
  CoordType get coordSystem => CoordType.single;
}

class SingleCoordConfig extends Coord {
  SingleCoordConfig({super.show, super.id});

  @override
  CoordType get coordSystem => CoordType.single;

  @override
  bool operator ==(Object other) => other is SingleCoordConfig && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
