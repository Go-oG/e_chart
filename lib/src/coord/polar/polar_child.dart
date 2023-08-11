import '../../model/data.dart';

abstract class PolarChild  {
  int get polarIndex {
    return 0;
  }

  List<dynamic> getAngleExtreme();

  List<dynamic> getRadiusExtreme();
}
