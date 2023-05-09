///记录全局数值信息
///最小、最大、平均数、中位数
class GlobalValue {
  ///存储在Stack组里面的相关信息
  final Map<String,ValueInfo> stackValueMap={};

  ///存储每个DataGroup的数值信息
  final Map<String,ValueInfo> groupValueMap={};

  ///存储每个坐标轴的数值信息
  final Map<String,ValueInfo> axisMap={};

  GlobalValue();

}

class ValueInfo{
  final num min ;
  final num max;
  final num ave ;
  final num median;
  ValueInfo(this.min, this.max, this.ave, this.median);
}
