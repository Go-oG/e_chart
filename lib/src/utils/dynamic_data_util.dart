import '../model/dynamic_data.dart';

extension DDStringExt on String {
  DynamicData toData() {
    return DynamicData(this);
  }
}

extension DNumExt on num {
  DynamicData toData() {
    return DynamicData(this);
  }
}

extension DDateTimeExt on DateTime {
  DynamicData toData() {
    return DynamicData(this);
  }
}

