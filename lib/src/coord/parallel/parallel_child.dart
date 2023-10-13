///在Parallel 坐标系里面的View 必须实现这个接口
abstract class ParallelChild {
  int get parallelIndex => 0;

  ///返回给定维度的极值
  List<dynamic> getDimExtreme(int dim);

  ///当Parallel 坐标系的数据发生改变时，会回调该方法
  ///子类应该实现该方法并重新布局
  void onParallelAxisChange(List<int> dims);

}
