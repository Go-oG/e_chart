/// 用于表示一个可能是百分比也可能是确切的数的对象
/// 当表示为百分比时，[percent]必须是一个0-100之间的数
class SNumber {
  static const SNumber zero = SNumber.number(0);
  final num number;
  final bool percent;

  const SNumber(this.number, this.percent);

  const SNumber.percent(this.number) : percent = true;

  const SNumber.number(this.number) : percent = false;

  double percentRatio() {
    return number / 100.0;
  }

  /// 给定一个数，如果当前对象是百分比则返回给定数的百分比
  /// 否则返回当前的值
  double convert(num data) {
    if (percent) {
      return data * percentRatio();
    }
    return number.toDouble();
  }

  bool isPositiveNumber() {
    return number > 0;
  }

  @override
  String toString() {
    return "number:${number.toStringAsFixed(2)} isPercent:$percent";
  }

}
