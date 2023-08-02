import '../model/data.dart';

extension DateTimeExt on DateTime {
  DynamicData toData() {
    return DynamicData(this);
  }
}
