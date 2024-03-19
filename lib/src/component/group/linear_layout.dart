import 'package:e_chart/e_chart.dart';

class LinearLayout extends ChartViewGroup {
  late Direction _direction;

  Direction get direction => _direction;

  set direction(Direction dir) {
    if (dir == _direction) {
      return;
    }
    _direction = dir;
    requestLayout();
  }

  LinearLayout(super.context, {Direction direction = Direction.vertical}) {
    _direction = direction;
  }

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    if (_direction == Direction.vertical) {
      measureVertical(widthSpec, heightSpec);
    } else {
      measureHorizontal(widthSpec, heightSpec);
    }
  }

  void measureVertical(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    final specMode = heightSpec.mode;
    final specSize = heightSpec.size;
    double totalHeight = 0;
    double totalWeight = 0;
    double maxWidth = 0;

    List<ChartView> weightList = [];
    List<ChartView> exactlyList = [];
    List<ChartView> matchList = [];

    for (var child in children) {
      if (child.visibility == Visibility.gone) {
        continue;
      }
      var lp = child.layoutParams;
      totalHeight += child.layoutParams.vMargin;

      ///一旦权重大于0 那么将忽略高度
      if (lp.weight > 0) {
        totalWeight += lp.weight;
        weightList.add(child);
        continue;
      }

      if (lp.height.isExactly) {
        measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
        maxWidth = max([maxWidth, child.measureWidth]);
        totalHeight += child.height;
        exactlyList.add(child);
        continue;
      }

      if (lp.height.isMatch) {
        if (specMode == SpecMode.exactly) {
          measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
          maxWidth = max([maxWidth, child.measureWidth]);

          totalHeight += child.height;
          exactlyList.add(child);
        } else {
          matchList.add(child);
        }
        continue;
      }
      //Wrap
      measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
      maxWidth = max([maxWidth, child.measureWidth]);

      totalHeight += child.height;
      exactlyList.add(child);
    }

    if (specMode == SpecMode.exactly) {
      var remainHeight = specSize - totalHeight;
      if (remainHeight >= 0) {
        for (var child in weightList) {
          var hh = remainHeight * child.layoutParams.weight / totalWeight;
          if (hh < 0) {
            throw ChartError("State Error");
          }
          var hSpec = MeasureSpec.exactly(hh);
          var old = child.layoutParams.height;
          child.layoutParams.height = SizeParams.exactly(hh);
          measureChildNotMargins(child, widthSpec, 0, hSpec, 0);
          maxWidth = max([maxWidth, child.measureWidth]);
          totalHeight += child.height;
          child.layoutParams.height = old;
        }
      } else {
        var cHSpec = const MeasureSpec.exactly(0);
        for (var child in weightList) {
          measureChildNotMargins(child, widthSpec, 0, cHSpec, 0);
          maxWidth = max([maxWidth, child.measureWidth]);
        }
      }
    } else {
      for (var child in [...weightList, ...matchList]) {
        measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
        totalHeight += child.height;
      }
    }

    double selfWidth = measureSelfSize(widthSpec, layoutParams.width, maxWidth + layoutParams.hPadding);
    var pWSpec = MeasureSpec.exactly(selfWidth);
    for (var child in children) {
      if (child.visibility.isGone) {
        continue;
      }
      var lp = child.layoutParams;
      var oldH = lp.height;
      lp.height = SizeParams.exactly(child.measureHeight);
      child.measure(pWSpec, heightSpec);
      lp.height = oldH;
    }

    setMeasuredDimension(maxWidth, totalHeight);
  }

  void measureHorizontal(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    final specMode = widthSpec.mode;
    final specSize = widthSpec.size;
    double totalWidth = 0;
    double totalWeight = 0;
    double maxHeight = 0;

    List<ChartView> weightList = [];
    List<ChartView> exactlyList = [];
    List<ChartView> matchList = [];

    for (var child in children) {
      if (child.visibility == Visibility.gone) {
        continue;
      }
      var lp = child.layoutParams;
      totalWidth += child.layoutParams.hMargin;

      ///一旦权重大于0 那么将忽略高度
      if (lp.weight > 0) {
        totalWeight += lp.weight;
        weightList.add(child);
        continue;
      }

      if (lp.width.isExactly) {
        measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
        maxHeight = max([maxHeight, child.measureHeight]);
        totalWidth += child.width;
        exactlyList.add(child);
        continue;
      }

      if (lp.width.isMatch) {
        if (specMode == SpecMode.exactly) {
          measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
          maxHeight = max([maxHeight, child.measureHeight]);
          totalWidth += child.width;
          exactlyList.add(child);
        } else {
          matchList.add(child);
        }
        continue;
      }
      //Wrap
      measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
      maxHeight = max([maxHeight, child.measureHeight]);

      totalWidth += child.width;
      exactlyList.add(child);
    }

    if (specMode == SpecMode.exactly) {
      var remainHeight = specSize - totalWidth;
      if (remainHeight >= 0) {
        for (var child in weightList) {
          var ww = remainHeight * child.layoutParams.weight / totalWeight;
          if (ww < 0) {
            throw ChartError("State Error");
          }
          var hSpec = MeasureSpec.exactly(ww);
          var old = child.layoutParams.width;
          child.layoutParams.width = SizeParams.exactly(ww);
          measureChildNotMargins(child, widthSpec, 0, hSpec, 0);
          child.layoutParams.width = old;

          maxHeight = max([maxHeight, child.measureHeight]);
          totalWidth += child.width;
        }
      } else {
        var cHSpec = const MeasureSpec.exactly(0);
        for (var child in weightList) {
          measureChildNotMargins(child, widthSpec, 0, cHSpec, 0);
          maxHeight = max([maxHeight, child.measureHeight]);
        }
      }
    } else {
      for (var child in [...weightList, ...matchList]) {
        var old = child.layoutParams.width;
        child.layoutParams.width = SizeParams.exactly(0);
        measureChildNotMargins(child, widthSpec, 0, heightSpec, 0);
        child.layoutParams.width = old;
        totalWidth += child.width;
      }
    }
    maxHeight += layoutParams.vPadding;
    double selfHeight = measureSelfSize(heightSpec, layoutParams.height, maxHeight);
    var pHSpec = MeasureSpec.exactly(selfHeight);
    for (var child in children) {
      if (child.visibility.isGone) {
        continue;
      }
      var lp = child.layoutParams;
      var oldW = lp.width;
      lp.width = SizeParams.exactly(child.measureHeight);
      child.measure(widthSpec, pHSpec);
      lp.width = oldW;
    }

    setMeasuredDimension(maxHeight, totalWidth);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    double offset = direction == Direction.vertical ? layoutParams.topPadding : layoutParams.leftPadding;
    var plp = layoutParams;
    for (var c in children) {
      var lp = c.layoutParams;
      if (direction == Direction.vertical) {
        c.layout(plp.leftPadding + lp.leftMargin, offset + lp.topMargin, plp.leftPadding + lp.leftMargin + c.width,
            offset + lp.topMargin + c.height);
        offset += c.height + lp.topMargin;
      } else {
        c.layout(offset + lp.leftMargin, plp.topPadding + lp.topMargin, offset + lp.leftMargin + c.width,
            plp.topPadding + lp.topMargin + c.height);
        offset += c.width + lp.leftMargin;
      }
    }
  }
}
