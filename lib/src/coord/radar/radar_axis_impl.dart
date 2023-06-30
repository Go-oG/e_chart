import '../../component/axis/impl/line_axis_impl.dart';
import 'radar_axis.dart';

class RadarAxisImpl extends LineAxisImpl<RadarAxis, LineProps> {
  RadarAxisImpl(super.axis, int index) : super(index: index);

  double dataToPoint(num data) {
    return scale.toRange(data)[0].toDouble();
  }
}
