import '../../model/string_number.dart';
import 'size_params.dart';

class LayoutParams {
  final SizeParams width;
  final SizeParams height;

  final SNumber leftMargin;
  final SNumber topMargin;
  final SNumber rightMargin;
  final SNumber bottomMargin;

  final SNumber leftPadding;
  final SNumber topPadding;
  final SNumber rightPadding;
  final SNumber bottomPadding;

  const LayoutParams(
      this.width,
      this.height, {
        this.leftMargin = SNumber.zero,
        this.topMargin = SNumber.zero,
        this.rightMargin = SNumber.zero,
        this.bottomMargin = SNumber.zero,
        this.leftPadding = SNumber.zero,
        this.topPadding = SNumber.zero,
        this.rightPadding = SNumber.zero,
        this.bottomPadding = SNumber.zero,
      });

  const LayoutParams.matchAll({
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.leftPadding = SNumber.zero,
    this.topPadding = SNumber.zero,
    this.rightPadding = SNumber.zero,
    this.bottomPadding = SNumber.zero,
  })  : width = const SizeParams.match(),
        height = const SizeParams.match();

  const LayoutParams.wrapAll({
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.leftPadding = SNumber.zero,
    this.topPadding = SNumber.zero,
    this.rightPadding = SNumber.zero,
    this.bottomPadding = SNumber.zero,
  })  : width = const SizeParams.wrap(),
        height = const SizeParams.wrap();

  double getLeftPadding(num size) {
    return leftPadding.convert(size);
  }

  double getTopPadding(num size) {
    return topPadding.convert(size);
  }

  double getRightPadding(num size) {
    return rightPadding.convert(size);
  }

  double getBottomPadding(num size) {
    return bottomPadding.convert(size);
  }

  double hPadding(num size) {
    return getLeftPadding(size) + getRightPadding(size);
  }

  double vPadding(num size) {
    return getTopPadding(size) + getBottomPadding(size);
  }

  double getLeftMargin(num size) {
    return leftMargin.convert(size);
  }

  double getTopMargin(num size) {
    return topMargin.convert(size);
  }

  double getRightMargin(num size) {
    return rightMargin.convert(size);
  }

  double getBottomMargin(num size) {
    return bottomMargin.convert(size);
  }

  double hMargin(num size) {
    return getLeftMargin(size) + getRightMargin(size);
  }

  double vMargin(num size) {
    return getTopMargin(size) + getBottomMargin(size);
  }
}