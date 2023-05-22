import 'rect_coord.dart';
import 'coord_layout.dart';

abstract class RectCoordLayout<T extends RectCoordinate> extends CoordinateLayout {
  final T props;

  RectCoordLayout(this.props){
    layoutParams=props.toLayoutParams();
  }
}
