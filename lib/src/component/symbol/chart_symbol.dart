import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Symbol实现
abstract class ChartSymbol {
  static final EmptySymbol empty = EmptySymbol();

  Size get size;

  AreaStyle itemStyle;
  LineStyle borderStyle;
  double scale = 1;

  ChartSymbol({this.itemStyle = AreaStyle.empty, this.borderStyle = LineStyle.empty});

  void draw(Canvas canvas, Paint paint, Offset offset) {
    if (scale <= 0) {
      return;
    }
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    onDraw(canvas, paint);
    canvas.restore();
  }

  void onDraw(Canvas canvas, Paint paint);

  bool contains(Offset center, Offset point);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }

  ChartSymbol lerp(covariant ChartSymbol end, double t);

  ChartSymbol copy(SymbolAttr? attr);

  ChartSymbol copyBySize(Size size) {
    return copy(SymbolAttr(size: size));
  }

  bool checkStyle() {
    var bs = borderStyle;
    var iss = itemStyle;
    if (bs.notDraw && (iss.notDraw)) {
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