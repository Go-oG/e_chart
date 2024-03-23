import '../../series/series.dart';
import '../context.dart';
import '../view/view.dart';

class SeriesFactory {
  static final SeriesFactory _instance = SeriesFactory._();

  static SeriesFactory get instance => _instance;

  SeriesFactory._();

  factory SeriesFactory() => _instance;
  late final List<SeriesConvert> _convertList = [];

  void addConvert(SeriesConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(SeriesConvert convert) {
    _convertList.remove(convert);
  }

  void clearConvert() {
    _convertList.clear();
  }

  ChartView? convert(Context context, ChartSeries series) {
    for (var sc in _convertList) {
      ChartView? v = sc.convert(context, series);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

abstract class SeriesConvert {
  ChartView? convert(Context context, ChartSeries series);
}
