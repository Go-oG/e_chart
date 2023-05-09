import 'package:flutter/material.dart';

import 'rect_coord.dart';
import 'coord_layout.dart';

abstract class RectCoordLayout<T extends RectCoordinate> extends CoordinateLayout {
  final T props;

  RectCoordLayout(this.props);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double w = parentWidth;
    double h = parentHeight;
    if (props.width != null) {
      w = props.width!.convert(parentWidth);
      double leftMargin = props.leftMargin.convert(parentWidth);
      double rightMargin = props.rightMargin.convert(parentWidth);
      if (w + leftMargin + rightMargin > parentWidth) {
        w = parentWidth - leftMargin - rightMargin;
      }
    } else {
      double leftMargin = props.leftMargin.convert(parentWidth);
      double rightMargin = props.rightMargin.convert(parentWidth);
      w = parentWidth - (leftMargin + rightMargin);
    }

    if (props.height != null) {
      h = props.height!.convert(parentHeight);
      double topMargin = props.topMargin.convert(parentHeight);
      double bottomMargin = props.bottomMargin.convert(parentHeight);
      if (h + topMargin + bottomMargin > parentHeight) {
        h = parentHeight - topMargin - bottomMargin;
      }
    } else {
      double topMargin = props.topMargin.convert(parentHeight);
      double bottomMargin = props.bottomMargin.convert(parentHeight);
      h = parentHeight - (topMargin + bottomMargin);
    }
    return Size(w, h);
  }
}
