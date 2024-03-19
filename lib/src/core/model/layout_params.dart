import 'package:e_chart/src/core/model/gravity.dart';

import 'size_params.dart';

class LayoutParams {
  static final LayoutParams none = LayoutParams.matchAll();
  SizeParams width;
  SizeParams height;
  Gravity gravity;
  double weight;

  double leftMargin;
  double topMargin;
  double rightMargin;
  double bottomMargin;

  double leftPadding;
  double topPadding;
  double rightPadding;
  double bottomPadding;

  LayoutParams(
    this.width,
    this.height, {
    this.weight = -1,
    this.gravity = Gravity.leftTop,
    this.leftMargin = 0,
    this.topMargin = 0,
    this.rightMargin = 0,
    this.bottomMargin = 0,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  LayoutParams.matchAll({
    this.gravity = Gravity.leftTop,
    this.weight = -1,
    this.leftMargin = 0,
    this.topMargin = 0,
    this.rightMargin = 0,
    this.bottomMargin = 0,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  })  : width = const SizeParams.match(),
        height = const SizeParams.match();

  LayoutParams.wrapAll({
    this.gravity = Gravity.leftTop,
    this.weight = 0,
    this.leftMargin = 0,
    this.topMargin = 0,
    this.rightMargin = 0,
    this.bottomMargin = 0,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  })  : width = const SizeParams.wrap(),
        height = const SizeParams.wrap();

  double get hPadding {
    return leftPadding + topPadding;
  }

  double get vPadding {
    return topPadding + bottomPadding;
  }

  double get hMargin {
    return leftMargin + rightMargin;
  }

  double get vMargin {
    return topMargin + bottomMargin;
  }
}
