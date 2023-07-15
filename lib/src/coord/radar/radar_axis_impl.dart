
import '../../component/axis/line/line_attrs.dart';
import '../../component/axis/line/line_axis_impl.dart';
import 'radar_axis.dart';

class RadarAxisImpl extends LineAxisImpl<RadarAxis, LineAxisAttrs> {
  RadarAxisImpl(super.context,super.axis,{super.axisIndex});

  double dataToRadius(num data) {
    return scale.toRange(data)[0].toDouble();
  }
}
