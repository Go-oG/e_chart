import '../../model/enums/coordinate.dart';
import '../coord.dart';
import '../coord_config.dart';

class SingleCoordConfig extends CoordConfig {
  SingleCoordConfig({super.show, super.id});

  @override
  CoordSystem get coordSystem => CoordSystem.single;

  @override
  bool operator ==(Object other) => other is SingleCoordConfig && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

///用于包装child
class SingleCoordImpl extends Coord {
  SingleCoordImpl() : super(SingleConfig());
}

class SingleConfig extends CoordConfig {
  SingleConfig({
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
  });

  @override
  CoordSystem get coordSystem => CoordSystem.single;
}
