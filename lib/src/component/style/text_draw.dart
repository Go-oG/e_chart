import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///用于优化文字绘制避免每次都需要测量
class TextDraw {
  static final empty = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero, emptyFlag: true);
  late final bool _emptyFlag;
  late LabelStyle _style;
  late DynamicText _text;
  Offset offset;
  Alignment align; //用于感知文本绘制位置
  num maxWidth;
  num minWidth;
  num maxHeight;
  num rotate; //文本相对于水平旋转的角度
  TextAlign textAlign;
  TextDirection textDirection;
  int? maxLines;
  String? ellipsis;
  bool ignoreOverText; //是否忽略绘制越界的文本
  num scaleFactor = 1; //文本缩放参数

  TextDraw(
    DynamicText text,
    LabelStyle style,
    this.offset, {
    this.align = Alignment.center,
    this.scaleFactor = 1,
    this.maxWidth = double.maxFinite,
    this.minWidth = 0,
    this.rotate = 0,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.maxHeight = double.maxFinite,
    this.ellipsis,
    this.ignoreOverText = false,
    bool emptyFlag = false,
  }) {
    _text = text;
    _style = style;
    _emptyFlag = emptyFlag;
  }

  DynamicText get text => _text;

  set text(DynamicText d) {
    if (_emptyFlag) {
      return;
    }
    updatePainter(text: d);
  }

  LabelStyle get style => _style;

  set style(LabelStyle s) {
    if (_emptyFlag) {
      return;
    }
    updatePainter(style: s);
  }

  Rect _textRect = Rect.zero;
  Size _testSize = Size.zero;

  Offset _textCenter = Offset.zero;
  Offset _textOffset = Offset.zero;

  TextPainter? _painter;

  TextPainter? _getPainter() {
    if (_emptyFlag) {
      return null;
    }
    if (text.isEmpty || !style.show || text.isParagraph) {
      return null;
    }
    var p = _painter;
    if (p != null) {
      return p;
    }
    TextSpan ts;
    if (text.isString) {
      ts = TextSpan(text: text.text, style: style.textStyle);
    } else {
      ts = text.text;
    }
    p = TextPainter(
        text: ts, textAlign: textAlign, textDirection: textDirection, textScaleFactor: 1, maxLines: maxLines);
    var textOverflow = style.overFlow == OverFlow.cut ? TextOverflow.clip : null;
    var ellipsis = textOverflow == TextOverflow.ellipsis ? '\u2026' : null;
    if (ellipsis != null) {
      p.ellipsis = ellipsis;
    }
    p.layout(minWidth: minWidth.toDouble(), maxWidth: maxWidth.toDouble());
    if (p.height > maxHeight) {
      int maxLineCount = maxHeight ~/ (p.height / p.computeLineMetrics().length);
      maxLineCount = max([1, maxLineCount]).toInt();
      p.maxLines = maxLineCount;
      p.layout(minWidth: minWidth.toDouble(), maxWidth: maxWidth.toDouble());
    }
    _painter = p;
    _textRect = Rect.fromCenter(center: Offset.zero, width: p.width, height: p.height);
    _testSize = _textRect.size;
    _textCenter = _computeAlignOffset(offset, align, p.width, p.height).translate(p.width / 2, p.height / 2);
    _textOffset = Offset(-p.width / 2, -p.height / 2);
    return p;
  }

  ParagraphConstraints? _constraints;

  Paragraph? _getParagraph() {
    if (_emptyFlag) {
      return null;
    }
    if (!text.isParagraph) {
      return null;
    }
    Paragraph? paragraph = text.text;
    if (paragraph == null) {
      return null;
    }

    var cs = _constraints;
    if (cs == null) {
      cs = ParagraphConstraints(width: maxWidth.toDouble());
      _constraints = cs;
      paragraph.layout(cs);
      var w = paragraph.width;
      var h = paragraph.height;
      _textCenter = _computeAlignOffset(offset, align, w, h).translate(w / 2, h / 2);
      _textOffset = Offset(-w / 2, -h / 2);
      _textRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      _testSize = _textRect.size;
    }
    return text.text;
  }

  void updatePainter({
    DynamicText? text,
    LabelStyle? style,
    Offset? offset,
    Alignment? align,
    double? scaleFactor,
    double? maxWidth,
    double? minWidth,
    double? rotate,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    double? maxHeight,
    String? ellipsis,
    bool? ignoreOverText,
  }) {
    if (_emptyFlag) {
      return;
    }
    _text = text ?? this.text;
    _style = style ?? this.style;
    this.offset = offset ?? this.offset;
    this.align = align ?? this.align;
    this.scaleFactor = scaleFactor ?? this.scaleFactor;
    this.maxWidth = maxWidth ?? this.maxWidth;
    this.minWidth = minWidth ?? this.minWidth;
    this.rotate = rotate ?? this.rotate;
    this.textAlign = textAlign ?? this.textAlign;
    this.textDirection = textDirection ?? this.textDirection;
    this.maxLines = maxLines ?? this.maxLines;
    this.maxHeight = maxHeight ?? this.maxHeight;
    this.ellipsis = ellipsis ?? this.ellipsis;
    this.ignoreOverText = ignoreOverText ?? this.ignoreOverText;
    _painter = null;
    _constraints = null;
    _textRect = Rect.zero;
    _testSize = Size.zero;
    _textCenter = Offset.zero;
    _textOffset = Offset.zero;
  }

  Size draw(CCanvas canvas, Paint paint) {
    if (_emptyFlag) {
      return Size.zero;
    }
    Size s1 = _drawTextSpan(canvas, paint);
    Size s2 = _drawParagraph(canvas, paint);
    if (s2.isEmpty) {
      return s1;
    }
    return s2;
  }

  Size _drawTextSpan(CCanvas canvas, Paint paint) {
    var painter = _getPainter();
    if (painter == null) {
      return Size.zero;
    }
    canvas.save();
    canvas.translate(_textCenter.dx, _textCenter.dy);
    if (scaleFactor != 1) {
      canvas.scale(scaleFactor.toDouble());
    }
    if (rotate % 360 != 0) {
      canvas.rotate(rotate * pi / 180);
    }
    style.decoration?.drawRect(canvas, paint, _textRect);
    painter.paint(canvas.canvas, _textOffset);
    canvas.restore();
    return _testSize;
  }

  Size _drawParagraph(CCanvas canvas, Paint paint) {
    var paragraph = _getParagraph();
    if (paragraph == null) {
      return Size.zero;
    }
    canvas.save();
    canvas.translate(_textCenter.dx, _textCenter.dy);
    if (scaleFactor != 1) {
      canvas.scale(scaleFactor.toDouble());
    }
    if (rotate % 360 != 0) {
      canvas.rotate(rotate * pi / 180);
    }
    style.decoration?.drawRect(canvas, paint, _textRect);
    canvas.drawParagraph(paragraph, _textOffset);
    canvas.restore();
    return _testSize;
  }

  Size getSize() {
    _getPainter();
    _getParagraph();
    return _testSize;
  }

  static Offset _computeAlignOffset(Offset offset, Alignment align, double textWidth, double textHeight) {
    double x = offset.dx;
    double y = offset.dy;
    double w = textWidth;
    double h = textHeight;
    x = x - (align.x + 1) * (w / 2);
    y = y - (align.y + 1) * (h / 2);
    return Offset(x, y);
  }

  bool get notDraw {
    return text.isEmpty || !style.show || _emptyFlag;
  }

  void dispose() {
    if (_emptyFlag) {
      return;
    }
    _style = LabelStyle.empty;
    _text = DynamicText.empty;
    _painter = null;
    _constraints = null;
  }

  static Offset offsetByRect(Rect rect, Alignment align) {
    return offsetByAlign(rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight, align);
  }

  static Offset offsetByAlign(Offset lt, Offset rt, Offset lb, Offset rb, Alignment align) {
    Offset p0 = lt;
    Offset p1 = rt;
    Offset p2 = rb;
    Offset p3 = lb;
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
    double topW = (p1.dx - p0.dx).abs();
    double x = centerX + align.x * topW / 2;
    double y = centerY + align.y * (p1.dy - p2.dy).abs() / 2;
    return Offset(x, y);
  }

  static Alignment alignConvert(Alignment align, [bool inside = true]) {
    Alignment textAlign = toInnerAlign(align);
    if (!inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    return textAlign;
  }
}
