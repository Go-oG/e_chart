import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xchart/src/ext/text_style_ext.dart';

import '../component/guideline/guide_line.dart';
import '../model/enums/over_flow.dart';
import '../model/text_position.dart';
import 'area_style.dart';

class LabelStyle {
  final bool show;
  final double rotate;
  final TextStyle textStyle;
  final AreaStyle? decoration;
  final OverFlow overFlow;
  final String ellipsis;
  final double lineMargin;
  final GuideLine guideLine;
  final double minAngle; //对应在扇形形状中小于好多时则不显示

  const LabelStyle({
    this.show = true,
    this.rotate = 0,
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.overFlow = OverFlow.cut,
    this.ellipsis = '',
    this.guideLine = const GuideLine(),
    this.lineMargin = 4,
    this.minAngle = 0,
  });

  Size draw(Canvas canvas, Paint paint, String text, TextDrawConfig config) {
    if (!show || text.isEmpty) {
      return Size.zero;
    }

    TextOverflow? textOverflow = overFlow == OverFlow.cut ? TextOverflow.clip : null;
    String? ellipsis = textOverflow == TextOverflow.ellipsis ? '\u2026' : null;
    TextPainter painter = textStyle.toPainter(
      text,
      ellipsis: config.ellipsis ?? ellipsis,
      maxLines: config.maxLines,
      textAlign: config.textAlign,
      textDirection: config.textDirection,
      textScaleFactor: config.scaleFactor.toDouble(),
    );
    painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());
    if (painter.height > config.maxHeight) {
      int maxLineCount = config.maxHeight ~/ (painter.height / painter.computeLineMetrics().length);
      maxLineCount = max(1, maxLineCount);
      painter = textStyle.toPainter(
        text,
        ellipsis: config.ellipsis ?? ellipsis,
        maxLines: maxLineCount,
        textAlign: config.textAlign,
        textDirection: config.textDirection,
        textScaleFactor: config.scaleFactor.toDouble(),
      );
      painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());
    }

    Offset leftTop = _computeAlignOffset(config.offset, config.align, painter.width, painter.height);
    Offset center = leftTop.translate(painter.width / 2, painter.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotate != 0) {
      canvas.rotate(rotate * pi / 180);
    }
    if (decoration != null) {
      Path path = Path();
      path.addRect(Rect.fromCenter(center: Offset.zero, width: painter.width, height: painter.height));
      decoration?.drawPath(canvas, paint, path);
    }

    Offset textOffset = Offset(-painter.width / 2, -painter.height / 2);
    painter.paint(canvas, textOffset);
    canvas.restore();
    return Size(painter.width, painter.height);
  }

  Size measure(String text, {num maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    TextPainter painter = textStyle.toPainter(text);
    painter.layout(maxWidth: maxWidth.toDouble());
    return painter.size;
  }

  /// 给定一个绘制点和对齐方式计算文本左上角的对齐点
  Offset _computeAlignOffset(Offset offset, Alignment align, double textWidth, double textHeight) {
    double x = offset.dx;
    double y = offset.dy;
    double w = textWidth;
    double h = textHeight;
    x = x - (align.x + 1) * (w / 2);
    y = y - (align.y + 1) * (h / 2);
    return Offset(x, y);
  }
}
