import '../model/data.dart';

extension StringExt on String {
  DynamicText toText() {
    return DynamicText(this);
  }

  DynamicData toData() {
    return DynamicData(this);
  }
}
