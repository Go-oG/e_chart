/// 线性同余算法 生成随机数
abstract class LCG {
  double lcg();
}

class DefaultLCG implements LCG {
  static const int a = 1664525;
  static const int c = 1013904223;
  static const int m = 4294967296; // 2^32
  double s = 1;

  @override
  double lcg() {
    s = (a * s + c) % m;
    return s / m;
  }
}
