import 'dart:math';

num clamp(num lower, num upper) {
  Random random = Random();
  var p = random.nextDouble();
  var diff = (upper - lower);
  return lower + diff * p;
}

List<int> range(int start, int end, [int step = 1]) {
  int index = -1;
  int length = max(((end - start) / step).ceil(), 0);
  List<int> rl = List.filled(length, 0);
  while ((length--) != 0) {
    rl[++index] = start;
    start += step;
  }
  return rl;
}

int lerpInt(int s, int e, num t) {
  if (s == e || (s.isNaN && e.isNaN)) {
    return s;
  }
  return (s + (e - s) * t).round();
}

double lerpNum(num s, num e, num t) {
  if (s == e || (s.isNaN && e.isNaN)) {
    return s.toDouble();
  }
  return s.toDouble() + (e - s) * t;
}
