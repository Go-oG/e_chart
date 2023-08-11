import '../model/data.dart';

extension StringExt on String {
  DynamicText toText() {
    return DynamicText(this);
  }

  num toNum() {
    return double.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }

  int toInt() {
    return int.parse(this);
  }
}
