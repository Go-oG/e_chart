import '../../component/brush/brush.dart';
import '../../component/brush/brush_view.dart';
import '../../model/enums/coordinate.dart';
import '../coord_impl.dart';
import '../coord.dart';

///用于包装child
class SingleCoordImpl extends CoordLayout {
  SingleCoordImpl() : super(SingleConfig());

  @override
  BrushView? onCreateBrushView(Brush brush) {
    return null;
  }
}

class SingleConfig extends Coord {
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

class SingleCoordConfig extends Coord {
  SingleCoordConfig({super.show, super.id});

  @override
  CoordSystem get coordSystem => CoordSystem.single;

  @override
  bool operator ==(Object other) => other is SingleCoordConfig && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
