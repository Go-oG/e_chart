import 'dart:math';

class AxisDim {
  static final List<AxisDim> _dimList = [
    const AxisDim(0),
    const AxisDim(1),
    const AxisDim(2),
    const AxisDim(3),
    const AxisDim(4),
    const AxisDim(5),
    const AxisDim(6),
    const AxisDim(7),
    const AxisDim(8),
    const AxisDim(9),
    const AxisDim(10),
  ];

  static AxisDim fromIndex(int index) {
    index = max(index, 0);
    if (index < _dimList.length) {
      return _dimList[index];
    }
    return AxisDim(index);
  }

  final int index;

  const AxisDim(this.index);
}
