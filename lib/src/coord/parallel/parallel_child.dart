
import '../../model/data.dart';
///在Parallel 坐标系里面的View 必须实现这个接口
abstract class ParallelChild{

  int get parallelIndex=>0;

  ///返回给定维度的数据集
  List<DynamicData> getDimDataSet(int dim);

}