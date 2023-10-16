import 'package:e_chart/e_chart.dart';

class SeriesViewScaleEvent extends ChartEvent {
  final ChartSeries series;
  final String viewId;
  double zoom;
  double originX;
  double originY;

  SeriesViewScaleEvent(this.series, this.viewId, this.zoom, this.originX, this.originY);

  @override
  EventType get eventType => EventType.seriesViewScale;
}

class SeriesViewTranslationEvent extends ChartEvent {
  final ChartSeries series;
  final String viewId;
  double translationX;
  double translationY;

  SeriesViewTranslationEvent(this.series, this.viewId, this.translationX, this.translationY);

  @override
  EventType get eventType => EventType.seriesViewTranslation;
}
