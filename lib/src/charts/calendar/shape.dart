import 'package:flutter/material.dart';

enum ShapeStyle { circle, square }

class CalendarShape {
  final ShapeStyle shape;
  final Color color;
  final bool fill;
  final double cornerRadius;
  const CalendarShape(this.shape, this.color, this.fill, this.cornerRadius);
  const CalendarShape.circle(Color color) : this(ShapeStyle.circle, color, true, 0);
}
