import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/view_port.dart';
import 'package:flutter/material.dart';

///负责处理和布局所有的子View
///包括了Brush、ToolTip相关组件
abstract class CoordLayout<T extends Coord> extends ChartViewGroup {
  final T props;

  late final CoordScale scale;

  double get scaleX => scale.dx;

  double get scaleY => scale.dy;

  late final ViewPort viewPort;

  double get scrollX => viewPort.scrollX;

  double get scrollY => viewPort.scrollY;

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  BrushView? _brushView;
  ToolTipView? _tipView;

  CoordLayout(this.props) : super() {
    layoutParams = props.layoutParams;
    scale = CoordScale(props.id, props.coordSystem, 1, 1);
    viewPort = ViewPort.zero();
  }

  @override
  void onCreate() {
    super.onCreate();
    if (props.brush != null) {
      _brushView = BrushView(this, props.brush!);
      addView(_brushView!);
    }
    var tooltip = findToolTip();
    if (tooltip != null) {
      ToolTip toolTip = ToolTip(show: false);
      _tipView = ToolTipView(toolTip);
      addView(_tipView!);
    }
  }

  ToolTip? findToolTip() {
    if (props.toolTip != null) {
      return props.toolTip;
    }
    return context.option.toolTip;
  }

  @override
  void onStart() {
    super.onStart();
    context.addEventCall(dispatchEvent);
    context.addActionCall(dispatchAction);
    registerCommandHandler();
    props.addListener(_handleCommand);
  }

  void _handleCommand() {
    onReceiveCommand(props.value);
  }

  @override
  void onStop() {
    context.removeEventCall(dispatchEvent);
    context.removeActionCall(dispatchAction);
    props.removeListener(_handleCommand);
    unregisterCommandHandler();
    super.onStop();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    setForceLayout();
    this.layout(left, top, right, bottom);
  }

  @override
  void dispatchDraw(CCanvas canvas) {
    List<ChartView> vl = [];
    for (var child in children) {
      int count = canvas.getSaveCount();
      if (child is BrushView || child is ToolTipView) {
        vl.add(child);
      } else {
        drawChild(child, canvas);
      }
      int n = canvas.getSaveCount();
      // if (n != count) {
      //   throw ChartError(
      //       '$runtimeType dispatchDraw(1) old:$count new:$n view:${child.runtimeType} you should call canvas.restore when after call canvas.save');
      // }
    }
    for (var child in vl) {
      int count = canvas.getSaveCount();
      drawChild(child, canvas);
      int n = canvas.getSaveCount();
      // if (n != count) {
      //   throw ChartError(
      //       '$runtimeType dispatchDraw(2) old:$count new:$n view:${child.runtimeType} you should call canvas.restore when after call canvas.save');
      // }
    }
  }

  @override
  void onDrawBackground(CCanvas canvas) {
    Color? color = props.backgroundColor;
    if (color == null) {
      return;
    }
    mPaint.reset();
    mPaint.color = color;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(selfBoxBound, mPaint);
  }

  @override
  void onBrushEvent(BrushEvent event) {
    if (_brushView == null || event.brushId != _brushView?.brush.id || event.coord != props.coordSystem) {
      return;
    }
    super.onBrushEvent(event);
  }

  @override
  void onBrushEndEvent(BrushEndEvent event) {
    if (_brushView == null || event.brushId != _brushView?.brush.id || event.coord != props.coordSystem) {
      return;
    }
    super.onBrushEndEvent(event);
  }

  @override
  void onBrushClearEvent(BrushClearEvent event) {
    if (_brushView == null || event.brushId != _brushView?.brush.id || event.coord != props.coordSystem) {
      return;
    }
    super.onBrushClearEvent(event);
  }

  @override
  bool get enableHover => true;

  @override
  bool get enableDrag => true;

  @override
  bool get enableClick => true;

  @override
  bool get enableScale => true;

  @override
  bool get enableLongPress => true;

  Offset getScaleFactor() {
    return Offset(scale.dx, scale.dy);
  }

  Offset getTranslation() {
    return viewPort.getTranslation();
  }

  ///获取滚动的最大量(都应该是整数)
  Offset getMaxScroll() {
    return Offset(getMaxXScroll(), getMaxYScroll());
  }

  double getMaxXScroll();

  double getMaxYScroll();

  ///返回不包含BrushView、ToolTipView的子视图列表
  List<ChartView> getChildNotComponent() {
    List<ChartView> vl = [];
    for (var v in children) {
      if (v is! BrushView || v is! ToolTipView) {
        vl.add(v);
      }
    }
    return vl;
  }

  List<ChartView> getComponentChild() {
    List<ChartView> vl = [];
    for (var v in children) {
      if (v is BrushView || v is ToolTipView) {
        vl.add(v);
      }
    }
    return vl;
  }
}
