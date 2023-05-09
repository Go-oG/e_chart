
import '../../model/dynamic_data.dart';

abstract class GridChild{

  int get xAxisIndex;

  int get yAxisIndex;

  int get xDataSetCount;

  int get yDataSetCount;

  List<DynamicData> get xDataSet;

  List<DynamicData> get yDataSet;

}