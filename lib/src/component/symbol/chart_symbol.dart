import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Symbol实现
abstract class ChartSymbol {
  static final EmptySymbol empty = EmptySymbol();

  Size get size;

  AreaStyle? itemStyle;
  LineStyle? borderStyle;

  ChartSymbol({this.itemStyle, this.borderStyle});

  void draw(Canvas canvas, Paint paint, Offset offset);

  bool contains(Offset center, Offset point);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }

  ChartSymbol lerp(covariant ChartSymbol end, double t);

  ChartSymbol copy(SymbolAttr? attr);

  bool checkStyle() {
    var bs = borderStyle;
    var iss = itemStyle;
    if ((bs == null || bs.notDraw) && (iss == null || iss.notDraw)) {
      return false;
    }
    return true;
  }
}

class SymbolAttr {
  static const empty = SymbolAttr();
  final Size? size;
  final double? ratio;
  final double? rotate;
  final int? borderCount;
  final Corner? corner;

  const SymbolAttr({
    this.size,
    this.rotate,
    this.ratio,
    this.borderCount,
    this.corner,
  });

  bool get isEmpty {
    return size == null && ratio == null && rotate == null && borderCount == null && corner == null;
  }
}
