import '../model/data.dart';
extension NumExt on num {
  DynamicData toData() {
    return DynamicData(this);
  }


}