import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///雷达图坐标系
class RadarCoordImpl extends RadarCoord {
  final Map<int, RadarAxisImpl> axisMap = {};
  final List<Path> shapePathList = [];
  Offset center = Offset.zero;
  double radius = 0;

  RadarCoordImpl(super.props) {
    for (int i = 0; i < props.indicator.length; i++) {
      var indicator = props.indicator[i];
      RadarAxis axis = RadarAxis(
          name: indicator.name,
          min: indicator.min,
          max: indicator.max,
          nameGap: indicator.nameGap,
          nameStyle: indicator.nameStyle,
          splitNumber: 5);
      axisMap[i] = RadarAxisImpl(axis, i);
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    axisMap.forEach((key, value) {
      value.context=context;
    });
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double minValue = min(parentWidth, parentHeight);
    double cv = props.radius.convert(minValue);
    cv = min(cv, minValue) * 2;
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
    num oa = props.offsetAngle;
    axisMap.forEach((key, value) {
      double angle = oa + value.index * itemAngle;
      Offset o = circlePoint(radius, angle, center);
      LineProps layoutProps = LineProps(Rect.zero, center, o);
      value.layout(layoutProps, collectChildData(value.index));
    });

    double radiusItem = radius / props.splitNumber;
    int axisCount = props.indicator.length;

    ///Shape
    shapePathList.clear();
    for (int i = 0; i < props.splitNumber; i++) {
      double r = radiusItem * (i + 1);
      Path path;
      if (props.shape == RadarShape.circle) {
        path = Circle(r: r, center: center).toPath(false);
      } else {
        path = PositiveShape(r: r, count: axisCount, center: center).toPath(false);
      }
      shapePathList.add(path);
    }

    ///布局孩子
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }

  List<DynamicData> collectChildData(int dim) {
    List<DynamicData> list = [];
    for (var child in children) {
      if (child is! RadarChild) {
        continue;
      }
      (child as RadarChild).dataSet(dim).forEach((element) {
        list.add(DynamicData(element));
      });
    }
    return list;
  }

  @override
  void onDraw(Canvas canvas) {
    _drawShape(canvas);
    _drawAxis(canvas);
  }

  void _drawShape(Canvas canvas) {
    for (int i = 0; i < shapePathList.length; i++) {
      Path path = shapePathList[i];
      AreaStyle? style = props.splitStyleFun?.call(i, i - 1);
      if (style != null) {
        Path tmpPath = path;
        if (i != 0) {
          tmpPath = Path.combine(PathOperation.difference, tmpPath, shapePathList[i - 1]);
        }
        style.drawPath(canvas, mPaint, tmpPath);
      }
      LineStyle? lineStyle = props.borderStyleFun?.call(i);
      lineStyle?.drawPath(canvas, mPaint, path);
    }
  }

  void _drawAxis(Canvas canvas) {
    ///绘制主轴
    AxisLine? axisLine = props.axisLine;
    if (axisLine != null && axisLine.show) {
      axisMap.forEach((key, value) {
        axisLine.style.drawPolygon(canvas, mPaint, [value.props.start, value.props.end]);
      });
    }

    ///绘制标签
    int i = 0;
    for (var indicator in props.indicator) {
      LabelStyle style =
          props.labelStyleFun?.call(indicator) ?? const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 14));
      if (!style.show) {
        i++;
        continue;
      }
      RadarAxisImpl node = axisMap[i]!;
      Offset offset = node.props.end;
      double angle = offset.offsetAngle();
      TextDrawConfig config = TextDrawConfig(offset, align: toAlignment(angle));
      style.draw(canvas, mPaint, indicator.name, config);
      i++;
    }
  }

  ///给定一个数据返回其对应数据在坐标系中的位置(视图位置为中心点)
  @override
  RadarPosition dataToPoint(int axisIndex, num data) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    RadarAxisImpl? node = axisMap[axisIndex];
    if (node == null) {
      throw ChartError("无法找到节点");
    }

    double angle = node.props.end.offsetAngle(node.props.start);
    double r = node.dataToPoint(data);
    return RadarPosition(center, r, angle);
  }

  @override
  int getAxisCount() => axisMap.length;

  @override
  Offset getCenter() => center;

  @override
  double getRadius() => radius;
}

abstract class RadarCoord extends CircleCoord<RadarConfig> {
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