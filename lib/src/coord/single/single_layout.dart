import 'package:e_chart/e_chart.dart';

import '../../core/view/render_node.dart';

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
    super.backgroundColor,
    super.id,
    super.show,
  }) : super(layoutParams: const LayoutParams.wrapAll());

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
