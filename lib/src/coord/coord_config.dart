import 'package:e_chart/e_chart.dart';

///坐标系
abstract class CoordConfig {
  final String id;
  final bool show;

  const CoordConfig({this.show = true, this.id = ''});

  CoordSystem get coordSystem;


}
