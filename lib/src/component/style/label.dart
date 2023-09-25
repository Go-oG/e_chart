import 'dart:math';
import 'dart:ui' show Paragraph, ParagraphConstraints;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LabelStyle {
  static const LabelStyle empty = LabelStyle(show: false);
  final bool show;
  final double rotate;
  final TextStyle textStyle;
  final AreaStyle? decoration;
  final OverFlow overFlow;
  final String ellipsis;
  final double lineMargin;
  final GuideLine? guideLine;
  final double minAngle; //对应在扇形形状中小于好多时则不显示

  const LabelStyle({
    this.show = true,
    this.rotate = 0,
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.overFlow = OverFlow.cut,
    this.ellipsis = '',
    this.guideLine,
    this.lineMargin = 4,
    this.minAngle = 0,
  });

  Size draw(CCanvas canvas, Paint paint, DynamicText text, TextDrawInfo config) {
    if (!show || text.isEmpty) {
      return Size.zero;
    }
    dynamic drawText = text.getDrawText(textStyle);
    if (drawText is TextSpan) {
      return drawTextSpan(canvas, paint, drawText, config);
    }
    return drawParagraph(canvas, paint, drawText as Paragraph, config);
  }

  Size drawText(CCanvas canvas, Paint paint, String text, TextDrawInfo config) {
    if (!show || text.isEmpty) {
      return Size.zero;
    }
    return drawTextSpan(canvas, paint, TextSpan(text: text, style: textStyle), config);
  }

  Size drawTextSpan(CCanvas canvas, Paint paint, TextSpan text, TextDrawInfo config) {
    if (!show || (text.text?.isEmpty ?? true)) {
      return Size.zero;
    }
    var textOverflow = overFlow == OverFlow.cut ? TextOverflow.clip : null;
    var ellipsis = textOverflow == TextOverflow.ellipsis ? '\u2026' : null;
    var painter = config.toPainter2(text);
    if (ellipsis != null) {
      painter.ellipsis = ellipsis;
    }
    painter.text = text;
    painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());

    if (painter.height > config.maxHeight) {
      int maxLineCount = config.maxHeight ~/ (painter.height / painter.computeLineMetrics().length);
      maxLineCount = max([1, maxLineCount]).toInt();
      painter.maxLines = maxLineCount;
      painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());
    }
    var leftTop = _computeAlignOffset(config.offset, config.align, painter.width, painter.height);
    var center = leftTop.translate(painter.width * 0.5, painter.height * 0.5);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (config.scaleFactor != 1) {
      canvas.scale(config.scaleFactor.toDouble());
    }
    if (rotate % 360 != 0) {
      canvas.rotate(rotate * pi / 180);
    }
    if (decoration != null) {
      Path path = Path();
      path.addRect(Rect.fromCenter(center: Offset.zero, width: painter.width, height: painter.height));
      decoration?.drawPath(canvas, paint, path);
    }

    var textOffset = Offset(-painter.width / 2, -painter.height / 2);
    painter.paint(canvas.canvas, textOffset);
    canvas.restore();
    return Size(painter.width, painter.height);
  }

  Size drawParagraph(CCanvas canvas, Paint paint, Paragraph paragraph, TextDrawInfo config) {
    var constraints = ParagraphConstraints(width: config.maxWidth.toDouble());
    paragraph.layout(constraints);
    double w = paragraph.width;
    double h = paragraph.height;
    Offset leftTop = _computeAlignOffset(config.offset, config.align, w, h);
    Offset center = leftTop.translate(w * 0.5, h * 0.5);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (config.scaleFactor != 1) {
      canvas.scale(config.scaleFactor.toDouble());
    }
    if (rotate % 360 != 0) {
      canvas.rotate(rotate * pi / 180);
    }
    if (decoration != null) {
      Path path = Path();
      path.addRect(Rect.fromCenter(center: Offset.zero, width: w, height: h));
      decoration?.drawPath(canvas, paint, path);
    }
    Offset textOffset = Offset(-w * 0.5, -h * 0.5);
    canvas.drawParagraph(paragraph, textOffset);
    canvas.restore();
    return Size(w, h);
  }

  Size measure(DynamicText text, {num maxWidth = double.infinity, int? maxLine}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    if (text.isString) {
      TextPainter painter = textStyle.toPainter(text.text as String, maxLines: maxLine);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    if (text.isTextSpan) {
      TextPainter painter = TextPainter(
          text: text.text as TextSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          textScaleFactor: 1,
          maxLines: maxLine,
          ellipsis: ellipsis);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    Paragraph p = text.text as Paragraph;
    ParagraphConstraints constraints = ParagraphConstraints(width: maxWidth.toDouble());
    p.layout(constraints);
    return Size(p.width, p.height);
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

  //TODO 待实现
  LabelStyle convert(Set<ViewState>? set) {
    return this;
  }
}
