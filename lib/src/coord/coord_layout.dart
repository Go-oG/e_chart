import '../core/view_group.dart';

///坐标系
abstract class CoordinateLayout extends ViewGroup{

  ///将给定的数据转换为对应的坐标点
 dynamic dataToPoint(covariant dynamic x,covariant dynamic y);

}

