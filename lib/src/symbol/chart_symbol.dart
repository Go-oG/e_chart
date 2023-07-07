import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/index.dart';
import 'package:flutter/material.dart';

import '../component/shader/shader.dart' as sd;

///Symbol实现
abstract class ChartSymbol {
  Offset center = Offset.zero;

  ChartSymbol({Offset center = Offset.zero});

  Size get size;

  ///绘制自身
  ///如果 info不为空，那么绘制时应该使用新的属性来绘制
  void draw(Canvas canvas, Paint paint, SymbolDesc info);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }

  bool internal(Offset point);
}

class SymbolDesc {
  static const empty = SymbolDesc();

  final List<Color> fillColor;
  final Color? borderColor;
  final num? borderWidth;
  final List<num> dash;
  final List<BoxShadow> shadow;
  final sd.Shader? shader;
  final Offset? center;
  final Size? size;

  const SymbolDesc({
    this.fillColor=const [],
    this.borderColor,
    this.borderWidth,
    this.dash=const [],
    this.shadow=const [],
    this.shader,
    this.center,
    this.size,
  });

  AreaStyle? toStyle() {
    Color? color = (fillColor == null || fillColor!.isEmpty) ? null : fillColor!.first;
    LineStyle? border;
    if (borderColor != null && borderWidth != null && borderWidth! > 0) {
      border = LineStyle(color: borderColor!, width: borderWidth!, dash: dash ?? [], shadow: shadow ?? [], shader: shader);
    }
    if (color != null || border != null) {
      return AreaStyle(color: color, border: border);
    }

    return null;
  }
}
