
import 'coord_layout.dart';

///坐标系
abstract class Coordinate {
  final String id;
  final bool show;

  const Coordinate({this.id = '', this.show = true});


  CoordinateLayout toLayout();
}
