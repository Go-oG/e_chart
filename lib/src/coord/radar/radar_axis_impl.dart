import '../../component/axis/impl/line_axis_impl.dart';
import 'radar_axis.dart';

class RadarAxisImpl extends LineAxisImpl<RadarAxis, LineProps> {
  RadarAxisImpl(super.axis,{super.axisIndex});

  double dataToRadius(num data) {
    return scale.toRange(data)[0].toDouble();
  }
}
