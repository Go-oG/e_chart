
import '../../model/dynamic_data.dart';

abstract class PolarChild {

  int get polarIndex{return 0;}

  List<DynamicData> get angleDataSet;

  List<DynamicData> get radiusDataSet;
}
