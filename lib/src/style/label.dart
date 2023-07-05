import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../core/view_state.dart';
import '../ext/text_style_ext.dart';
import '../component/guideline/guide_line.dart';
import '../model/dynamic_text.dart';
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

  Size draw(Canvas canvas, Paint paint, DynamicText text, TextDrawConfig config, [Set<ViewState>? states]) {
    if (!show || text.isEmpty) {
      return Size.zero;
    }
    if (text.isString) {
      return drawText(canvas, paint, text.text as String, config, states);
    }
    if (text.isTextSpan) {
      return drawTextSpan(canvas, paint, text.text as TextSpan, config);
    }
    return drawParagraph(canvas, paint, text.text as Paragraph, config);
  }

  Size drawText(Canvas canvas, Paint paint, String text, TextDrawConfig config, [Set<ViewState>? states]) {
    if (!show || text.isEmpty) {
      return Size.zero;
    }
    TextStyle style = textStyle;
    if (states != null && style.color != null) {
      style = style.copyWith(color: ColorResolver(style.color!).resolve(states)!);
    }
    return drawTextSpan(canvas, paint, TextSpan(text: text, style: style), config);
  }

  Size drawTextSpan(Canvas canvas, Paint paint, TextSpan text, TextDrawConfig config) {
    if (!show || (text.text?.isEmpty ?? true)) {
      return Size.zero;
    }
    TextOverflow? textOverflow = overFlow == OverFlow.cut ? TextOverflow.clip : null;
    String? ellipsis = textOverflow == TextOverflow.ellipsis ? '\u2026' : null;
    TextPainter painter = config.toPainter2(text);
    if (config.ellipsis == null) {
      painter.ellipsis = ellipsis;
    }
    painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());
    if (painter.height > config.maxHeight) {
      int maxLineCount = config.maxHeight ~/ (painter.height / painter.computeLineMetrics().length);
      maxLineCount = max(1, maxLineCount);
      painter.maxLines = maxLineCount;
      painter.layout(minWidth: config.minWidth.toDouble(), maxWidth: config.maxWidth.toDouble());
    }
    Offset leftTop = _computeAlignOffset(config.offset, config.align, painter.width, painter.height);
    Offset center = leftTop.translate(painter.width * 0.5, painter.height * 0.5);
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

    Offset textOffset = Offset(-painter.width * 0.5, -painter.height * 0.5);
    painter.paint(canvas, textOffset);
    canvas.restore();
    return Size(painter.width, painter.height);
  }

  Size drawParagraph(Canvas canvas, Paint paint, Paragraph paragraph, TextDrawConfig config) {
    ParagraphConstraints constraints = ParagraphConstraints(width: config.maxWidth.toDouble());
    paragraph.layout(constraints);
    double w = paragraph.width;
    double h = paragraph.height;
    Offset leftTop = _computeAlignOffset(config.offset, config.align, w, h);
    Offset center = leftTop.translate(w * 0.5, h * 0.5);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotate != 0) {
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
  LabelStyle convert(Set<ViewState> set){
    return this;
  }



}
