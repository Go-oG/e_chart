import 'package:e_chart/e_chart.dart';

///检查给定的两个数据的引用地址是否一样
///如果一样则抛出异常
void checkRef(dynamic a, dynamic b, [String? msg]) {
  if (a == null && b == null) {
    return;
  }
  if (identical(a, b)) {
    throw ChartError(msg ?? "a b引用的地址相同");
  }
}
