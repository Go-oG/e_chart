
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/bar/BarGridView.dart';

import '../../charts/bar/bar_chart.dart';
import '../../charts/bar/bar_series.dart';
import '../../charts/boxplot/boxplot_chart.dart';
import '../../charts/boxplot/boxplot_series.dart';
import '../../charts/calendar/calendar_chart.dart';
import '../../charts/calendar/calendar_series.dart';
import '../../charts/candlestick/candlestick_chart.dart';
import '../../charts/candlestick/candlestick_series.dart';
import '../../charts/funnel/funnel_chart.dart';
import '../../charts/funnel/funnel_series.dart';
import '../../charts/heatmap/heat_map_chart.dart';
import '../../charts/heatmap/heat_map_series.dart';
import '../../charts/line/line_chart.dart';
import '../../charts/line/line_series.dart';
import '../../charts/parallel/parallel_chart.dart';
import '../../charts/parallel/parallel_series.dart';
import '../../charts/pie/pie_chart.dart';
import '../../charts/pie/pie_series.dart';
import '../../charts/point/point_chart.dart';
import '../../charts/point/point_series.dart';
import '../../charts/radar/radar_chart.dart';
import '../../charts/radar/radar_series.dart';
import '../series.dart';
import '../view.dart';

class SeriesFactory {
  static final SeriesFactory _instance = SeriesFactory._();

  static SeriesFactory get instance => _instance;

  SeriesFactory._() {
    _convertList.add(_defaultConvert);
  }

  factory SeriesFactory() => _instance;
  final DefaultSeriesConvert _defaultConvert = DefaultSeriesConvert();
  final List<SeriesConvert> _convertList = [];

  void addConvert(SeriesConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(SeriesConvert convert) {
    if (convert == _defaultConvert) {
      return;
    }
    _convertList.remove(convert);
  }

  void clearConvert() {
    _convertList.clear();
    _convertList.add(_defaultConvert);
  }

  ChartView? convert(ChartSeries series) {
    for (var sc in _convertList) {
      ChartView? v = sc.convert(series);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

class DefaultSeriesConvert extends SeriesConvert {
  @override
  ChartView? convert(ChartSeries series) {
    if (series is LineSeries) {
      return LineView(series);
    }
    if (series is BarSeries) {
      if(series.coordSystem!=CoordSystem.polar){
        return BarGridView(series);
      }
      return BarView(series);
    }
    if (series is CandleStickSeries) {
      return CandleStickView(series);
    }
    if (series is BoxplotSeries) {
      return BoxPlotView(series);
    }
    if (series is HeatMapSeries) {
      return HeatMapView(series);
    }
    if (series is PointSeries) {
      return PointView(series);
    }
    if (series is CalenderSeries) {
      return CalendarView(series);
    }
    if (series is FunnelSeries) {
      return FunnelView(series);
    }
    if (series is ParallelSeries) {
      return ParallelView(series);
    }
    if (series is PieSeries) {
      return PieView(series);
    }
    if (series is RadarSeries) {
      return RadarView(series);
    }
    return null;
  }
}

abstract class SeriesConvert {
  ChartView? convert(ChartSeries series);
}
