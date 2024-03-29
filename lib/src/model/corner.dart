class Corner {
  static const zero = Corner(0, 0, 0, 0);
  final double leftTop;
  final double rightTop;
  final double leftBottom;
  final double rightBottom;

  const Corner(this.leftTop, this.rightTop, this.leftBottom, this.rightBottom);

  const Corner.all(double v)
      : leftTop = v,
        rightTop = v,
        leftBottom = v,
        rightBottom = v;

  const Corner.only({
    this.leftTop = 0,
    this.leftBottom = 0,
    this.rightTop = 0,
    this.rightBottom = 0,
  });
}
