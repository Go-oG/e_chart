import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xchart/src/coord/circle_coord_layout.dart';

import '../../component/axis/impl/arc_axis_impl.dart';
import '../../component/axis/impl/line_axis_impl.dart';

import '../../ext/offset_ext.dart';
import '../../gesture/chart_gesture.dart';
import '../../model/dynamic_data.dart';
import 'axis_radius_node.dart';
import 'polar.dart';
import 'polar_child.dart';

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarLayout extends CircleCoordLayout<Polar> {
  late final ArcAxisImpl _angleAxis;
  late final RadiusAxisImpl _radiusAxis;
  final ArcGesture gesture = ArcGesture();

  Offset? _clickOffset;

  PolarLayout(super.props) {
    _angleAxis = ArcAxisImpl(props.angleAxis);
    _radiusAxis = RadiusAxisImpl(props.radiusAxis);
  }

  @override
  void onAttach() {
    super.onAttach();
    context.gestureDispatcher.addGesture(gesture);
    gesture.edgeFun = (offset) {
      return globalAreaBound.contains(offset);
    };
    gesture.hoverStart = (e) {
      _handleHoverWithDrag(e.globalPosition);
    };
    gesture.hoverMove = (e) {
      _handleHoverWithDrag(e.globalPosition);
    };
    gesture.hoverEnd = (e) {
      _handleHoverWithDrag(null);
    };
    gesture.longPressStart = (e) {
      _handleHoverWithDrag(e.globalPosition);
    };
    gesture.longPressMove = (e) {
      _handleHoverWithDrag(e.globalPosition);
    };
    gesture.longPressEnd = (e) {
      _handleHoverWithDrag(null);
    };
    gesture.longPressCancel = () {
      _handleHoverWithDrag(null);
    };
  }

  void _handleHoverWithDrag(Offset? globalOffset) {
    if (globalOffset == null) {
      if (_clickOffset == null) {
        return;
      }
      _clickOffset = null;
      invalidate();
      return;
    }
    _clickOffset = null;
    if (props.silent) {
      return;
    }
    _clickOffset = toLocalOffset(globalOffset);
    invalidate();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double size = min(parentWidth, parentHeight);
    size = props.radius.convert(size) * 2;
    return Size(size, size);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double r = width / 2;
    ArcProps angleProps = ArcProps(
      Offset.zero,
      props.angleAxis.offsetAngle.toDouble(),
      r + props.angleAxis.radiusOffset,
    );
    LineProps radiusProps = LineProps(areaBounds, Offset.zero, circlePoint(r, props.radiusAxis.offsetAngle));
    _angleAxis.layout(angleProps, _getAngleDataSet());
    _radiusAxis.layout(radiusProps, _getRadiusDataSet());
    gesture.startAngle = 0;
    gesture.sweepAngle = 360;
    gesture.innerRadius = 0;
    gesture.outerRadius = r;
  }

  List<DynamicData> _getAngleDataSet() {
    List<DynamicData> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.angleDataSet);
    }
    return list;
  }

  List<DynamicData> _getRadiusDataSet() {
    List<DynamicData> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.radiusDataSet);
    }
    return list;
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(width / 2, height / 2);
    _angleAxis.draw(canvas, paint);
    _radiusAxis.draw(canvas, paint);
    canvas.restore();
  }

  @override
  void onDrawEnd(Canvas canvas) {
    canvas.save();
    canvas.translate(width / 2, height / 2);
    drawClickNode(canvas);
    canvas.restore();
  }

  void drawClickNode(Canvas canvas) {
    if (_clickOffset == null) {
      return;
    }

    Offset offset = _clickOffset!.translate(-width / 2, -height / 2);
    double angle = offset.offsetAngle();
    double r = offset.distance2(Offset.zero);
    if (r > width / 2) {
      r = width / 2;
    }
    props.angleAxis.tipLineStyle?.drawArc(canvas, paint, r, 0, 360);
    props.radiusAxis.tipLineStyle?.drawPolygon(canvas, paint, [Offset.zero, circlePoint(width / 2, angle)]);
  }

  @override
  Offset dataToPoint(dynamic angleData, dynamic radiusData) {
    num angle = _angleAxis.dataToAngle(angleData);
    num r = _radiusAxis.dataToRadius(radiusData);
    return circlePoint(r, angle);
  }
}
