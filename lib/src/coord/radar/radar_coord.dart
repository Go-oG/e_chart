import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///雷达图坐标系
class RadarCoordImpl extends RadarCoord {
  final Map<RadarIndicator, RadarAxisImpl> axisMap = {};
  final List<RadarSplit> splitList = [];

  Offset center = Offset.zero;
  double radius = 0;

  RadarCoordImpl(super.props);

  @override
  void onCreate() {
    super.onCreate();
    axisMap.clear();
    for (int i = 0; i < props.indicator.length; i++) {
      var indicator = props.indicator[i];
      AxisName axisName = AxisName(
        indicator.name,
        nameGap: indicator.nameGap,
        labelStyle: indicator.nameStyle,
      );
      RadarAxis axis = RadarAxis(axisName: axisName, min: indicator.min, max: indicator.max, splitNumber: 5);
      axisMap[indicator] = RadarAxisImpl(context, this, axis, axisIndex: i);
    }
  }

  Size measureSize = Size.zero;

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    measureSize = Size(parentWidth, parentHeight);
    num minValue = min([parentWidth, parentHeight]);
    double cv = props.radius.last.convert(minValue);
    cv = min([cv, minValue]) * 2;
    return Size(cv, cv);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    center = Offset(props.center[0].convert(width), props.center[1].convert(height));
    double itemAngle = 360 / props.indicator.length;
    if (!props.clockwise) {
      itemAngle *= -1;
    }

    radius = width / 2;

    ///布局Axis
    num oa = props.offsetAngle;
    each(props.indicator, (p0, i) {
      var axis = axisMap[p0]!;
      double angle = oa + i * itemAngle;
      Offset o = circlePoint(radius, angle, center);
      var attrs = LineAxisAttrs(scaleX, scrollX, Rect.zero, center, o);
      axis.doLayout(attrs, collectChildData(i));
    });

    double rInterval = radius / props.splitNumber;
    int axisCount = props.indicator.length;

    ///Shape Path
    splitList.clear();
    Path? lastPath;
    for (int i = 0; i < props.splitNumber; i++) {
      double r = rInterval * (i + 1);
      Path path;
      if (props.shape == RadarShape.circle) {
        path = Circle(r: r, center: center).toPath();
      } else {
        path = PositiveShape(r: r, count: axisCount, center: center, angleOffset: props.offsetAngle).toPath();
      }
      if (lastPath == null) {
        lastPath = path;
        splitList.add(RadarSplit(i, path));
      } else {
        Path p2 = Path.combine(PathOperation.difference, path, lastPath);
        splitList.add(RadarSplit(i, p2));
        lastPath = path;
      }
    }

    ///布局孩子
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }

  List<dynamic> collectChildData(int dim) {
    List<dynamic> list = [];
    for (var child in children) {
      if (child is! RadarChild) {
        continue;
      }
      (child as RadarChild).dataSet(dim).forEach((element) {
        list.add(element);
      });
    }
    return list;
  }

  @override
  void onDraw(CCanvas canvas) {
    _drawShape(canvas);
    _drawAxis(canvas);
  }

  void _drawShape(CCanvas canvas) {
    var theme = context.option.theme.radarTheme;
    each(splitList, (sp, i) {
      AreaStyle? style;
      if (props.splitAreaStyleFun != null) {
        style = props.splitAreaStyleFun?.call(i, i - 1);
      } else {
        style = theme.getSplitAreaStyle(i);
      }
      style?.drawPath(canvas, mPaint, sp.splitPath);

      LineStyle? lineStyle;
      if (props.splitAreaStyleFun != null) {
        lineStyle = props.splitLineStyleFun?.call(i, i - 1);
      } else {
        lineStyle = theme.getSplitLineStyle(i);
      }
      lineStyle?.drawPath(canvas, mPaint, sp.splitPath);
    });
  }

  void _drawAxis(CCanvas canvas) {
    ///绘制主轴
    axisMap.forEach((key, value) {
      value.draw(canvas, mPaint, boxBounds);
    });
  }

  ///给定一个数据返回其对应数据在坐标系中的位置(视图位置为中心点)
  @override
  RadarPosition dataToPoint(int axisIndex, num data) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    RadarAxisImpl? node = axisMap[props.indicator[axisIndex]];
    if (node == null) {
      throw ChartError("无法找到节点");
    }
    double angle = node.attrs.end.angle(node.attrs.start);
    double r = node.dataToRadius(data);
    return RadarPosition(center, r, angle);
  }

  @override
  int getAxisCount() => axisMap.length;

  @override
  Offset getCenter() => center;

  @override
  double getRadius() => radius;

  @override
  double getMaxXScroll() {
    return 0;
  }

  @override
  double getMaxYScroll() {
    return 0;
  }
}

abstract class RadarCoord extends CircleCoordLayout<Radar> {
  RadarCoord(super.props);

  RadarPosition dataToPoint(int axisIndex, num data);

  int getAxisCount();

  Offset getCenter();

  double getRadius();
}

class RadarPosition {
  final Offset center;
  final num radius;
  final num angle;

  RadarPosition(this.center, this.radius, this.angle);

  Offset get point {
    return circlePoint(radius, angle, center);
  }
}

class RadarSplit {
  final int index;
  final Path splitPath;

  RadarSplit(this.index, this.splitPath);
}
