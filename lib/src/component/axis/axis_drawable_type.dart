enum AxisDrawableType {
  splitArea(1),
  splitLine(2),
  line(3),
  tick(4),
  label(5),
  title(6);

  final int priority;

  const AxisDrawableType(this.priority);
}
