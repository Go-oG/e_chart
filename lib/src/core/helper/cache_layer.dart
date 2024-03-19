import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

class CacheLayer {
  late final LayerHandle<Layer> _layer = LayerHandle();

  double _width = 0;
  double _height = 0;
  double _translationX = 0;
  double _translationY = 0;
  double _scale = 1;

  CacheLayer();

  Layer? get layer => _layer.layer;

  void save(Layer? layer, double w, double h, double tx, double ty, double scale) {
    _layer.layer = layer;
    _width = w;
    _height = h;
    _translationX = tx;
    _translationY = ty;
    _scale = scale;
  }

  void saveByView(Layer? layer, ChartView view) {
    _layer.layer = layer;
    _width = view.width;
    _height = view.height;
    _translationX = view.translationX;
    _translationY = view.translationY;
    _scale = view.scaleX;
  }

  bool hasChange(double w, double h, double tx, double ty, double scale) {
    var epsilon = StaticConfig.epsilon;
    if ((w - _width).abs() > epsilon) {
      return true;
    }
    if ((h - _height).abs() > epsilon) {
      return true;
    }
    if ((tx - _translationX).abs() > epsilon) {
      return true;
    }
    if ((ty - _translationY).abs() > epsilon) {
      return true;
    }
    if ((scale - _scale).abs() > epsilon) {
      return true;
    }

    return false;
  }

  bool notChange(double w, double h, double tx, double ty, double scale) {
    return !hasChange(w, h, tx, ty, scale);
  }

  void clear() {
    _layer.layer = null;
    _width = -1;
    _height = -1;
    _translationY = _translationX = 0;
    _scale = 1;
  }
}
