import 'package:e_chart/e_chart.dart';

class SeriesViewScaleEvent extends ChartEvent {
  ChartSeries? _series;

  ChartSeries? get series => _series;
  final String viewId;
  double zoom;
  double originX;
  double originY;

  SeriesViewScaleEvent(ChartSeries series, this.viewId, this.zoom, this.originX, this.originY) {
    _series = series;
  }

  @override
  EventType get eventType => EventType.seriesViewScale;

  @override
  void dispose() {
    super.dispose();
    _series = null;
  }
}

class SeriesViewTranslationEvent extends ChartEvent {
  ChartSeries? _series;

  ChartSeries? get series => _series;

  final String viewId;
  double translationX;
  double translationY;

  SeriesViewTranslationEvent(ChartSeries series, this.viewId, this.translationX, this.translationY) {
    _series = series;
  }

  @override
  EventType get eventType => EventType.seriesViewTranslation;

  @override
  void dispose() {
    super.dispose();
    _series = null;
  }
}
