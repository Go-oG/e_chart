import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import 'radar_axis.dart';

class RadarAxisNode extends LineAxisImpl<RadarAxis, LineProps> {
  RadarAxisNode(super.axis, int index) : super(index: index);

  double dataToPoint(num data) {
    return scale.rangeValue(DynamicData(data)).toDouble();
  }
}
