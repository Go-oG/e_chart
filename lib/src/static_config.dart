import 'dart:math';

///存放全局的静态配置
class StaticConfig {
  static const angleUnit = pi / 180;

  ///这里取53 是为了兼容Web
  static const int intMax = 2 ^ 53 - 1;

  ///贝塞尔曲线曲率
  static double smoothRatio = 0.18;

  ///用于确定比例尺缩放相关（映射标准步长值）
  ///更改该参数将影响所有坐标轴的缩放步进值
  ///每个数值必须在(0,1]之间
  ///通常常用的可以为[0.1,0.2.0.3.0.4,0.5,1]
  static List<num> scaleSteps = List.from([0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1], growable: false);
}
