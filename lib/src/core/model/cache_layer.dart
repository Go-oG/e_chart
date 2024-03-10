import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

class CacheLayer {
  late final LayerHandle<Layer> _layer = LayerHandle();

  double _width = 0;
  double _height = 0;
  double _translationX = 0;
  double _translationY = 0;
  double _scaleX = 1;
  double _scaleY = 1;

  CacheLayer();

  Layer? get layer => _layer.layer;

  void save(Layer? layer, double w, double h, double tx, double ty, double sx, double sy) {
    _layer.layer = layer;
    _width = w;
    _height = h;
    _translationX = tx;
    _translationY = ty;
    _scaleX = sx;
    _scaleY = sy;
  }

  void saveByView(Layer? layer, ViewAttr attr) {
    _layer.layer = layer;
    _width = attr.width;
    _height = attr.height;
    _translationX = attr.translationX;
    _translationY = attr.translationY;
    _scaleX = attr.scaleX;
    _scaleY = attr.scaleY;
  }

  bool hasChange(double w, double h, double tx, double ty, double sx, double sy) {
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
    if ((sx - _scaleX).abs() > epsilon) {
      return true;
    }
    if ((sy - _scaleY).abs() > epsilon) {
      return true;
    }
    return false;
  }

  bool notChange(double w, double h, double tx, double ty, double sx, double sy) {
    return !hasChange(w, h, tx, ty, sx, sy);
  }

  void clear() {
    _layer.layer = null;
    _width = -1;
    _height = -1;
    _translationY = _translationX = 0;
    _scaleX = _scaleY = 1;
  }
}
