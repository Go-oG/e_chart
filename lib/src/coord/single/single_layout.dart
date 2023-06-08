import 'package:uuid/uuid.dart';

import '../../model/enums/coordinate.dart';
import '../coord.dart';
import '../coord_config.dart';

class SingleCoordConfig extends CoordConfig {
  SingleCoordConfig({
    super.show,
  }) : super(id: const Uuid().v4().toString().replaceAll('-', ''));

  @override
  CoordSystem get coordSystem => CoordSystem.single;

  @override
  bool operator ==(Object other) => other is SingleCoordConfig && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

///用于包装child
class SingleCoordImpl extends Coord {
  SingleCoordImpl();
}
