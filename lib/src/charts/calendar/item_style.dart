import 'package:flutter/material.dart';

import 'shape.dart';
import 'font_style.dart' as cf;

class CalendarItemStyle {
  bool? drawNode;
  cf.FontStyle? labelStyle;
  bool? drawShape;
  CalendarShape? shape;
  bool drawMarking;
  CalendarShape? markingShape;
  num? markingShapeSize;
  bool? drawLine;
  Color? lineColor;
  Color? backgroundColor;

  CalendarItemStyle(
      {this.drawNode = true,
      this.labelStyle,
      this.drawShape,
      this.shape,
      this.drawMarking = false,
      this.markingShape,
      this.markingShapeSize,
      this.drawLine,
      this.lineColor,
      this.backgroundColor});
}
