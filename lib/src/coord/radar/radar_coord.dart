import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///雷达图坐标系
class RadarCoordImpl extends RadarCoord {
  final Map<int, RadarAxisImpl> axisMap = {};

  final List<RadarSplit> splitList = [];

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
      axisMap[i] = RadarAxisImpl(axis, axisIndex: i);
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    axisMap.forEach((key, value) {
      value.context = context;
    });
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    num minValue = min([parentWidth, parentHeight]);
    double cv = props.radius.convert(minValue);
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
    num oa = props.offsetAngle;
    axisMap.forEach((key, value) {
      double angle = oa + value.axisIndex * itemAngle;
      Offset o = circlePoint(radius, angle, center);
      LineProps layoutProps = LineProps(Rect.zero, center, o);
      value.layout(layoutProps, collectChildData(value.axisIndex));
    });

    double radiusItem = radius / props.splitNumber;
    int axisCount = props.indicator.length;

    ///Shape Path
    splitList.clear();
    Path? lastPath;
    for (int i = 0; i < props.splitNumber; i++) {
      double r = radiusItem * (i + 1);
      Path path;
      if (props.shape == RadarShape.circle) {
        path = Circle(r: r, center: center).toPath(false);
      } else {
        path = PositiveShape(r: r, count: axisCount, center: center).toPath(false);
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
    var theme = context.config.theme.radarTheme;
    each(splitList, (sp, i) {
      AreaStyle? style;
      if (props.splitStyleFun != null) {
        style = props.splitStyleFun?.call(i, i - 1);
      } else {
        style = theme.getSplitAreaStyle(i);
      }
      style?.drawPath(canvas, mPaint, sp.splitPath);

      LineStyle? lineStyle;
      if (props.splitStyleFun != null) {
        lineStyle = props.splitStyleFun?.call(i, i - 1).border;
      } else {
        lineStyle = theme.getSplitLineStyle(i);
      }
      lineStyle?.drawPath(canvas, mPaint, sp.splitPath);
    });
  }

  void _drawAxis(Canvas canvas) {
    ///绘制主轴
    axisMap.forEach((key, value) {
      value.draw(canvas, mPaint, boxBounds);
    });

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

class RadarSplit {
  final int index;
  final Path splitPath;

  RadarSplit(this.index, this.splitPath);
}
