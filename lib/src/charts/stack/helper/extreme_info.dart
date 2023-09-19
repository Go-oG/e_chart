import '../index.dart';

///存储坐标轴上的极值信息
class ExtremeInfo {
  ///如果为true 表明是X轴方向的极值数据
  ///如果为false 表明为Y轴方向上的极值数据
  final bool xAxis;
  final AxisIndex axisIndex;
  final List<num> numExtreme;
  final List<String> strExtreme;
  final List<DateTime> timeExtreme;

  late List<dynamic> _info;

  ExtremeInfo(this.xAxis, this.axisIndex, this.numExtreme, this.strExtreme, this.timeExtreme) {
    _info = [...numExtreme, ...strExtreme, ...timeExtreme];
  }

  void syncData() {
    _info = [...numExtreme, ...strExtreme, ...timeExtreme];
  }

  List<dynamic> getAllExtreme() {
    return _info;
  }
}
