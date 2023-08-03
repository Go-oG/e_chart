import '../../model/data.dart';

abstract class PolarChild  {
  int get polarIndex {
    return 0;
  }

  List<DynamicData> getAngleDataSet();

  List<DynamicData> getRadiusDataSet();
}
