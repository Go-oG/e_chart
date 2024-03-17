import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///负责处理和布局所有的子View
///包括了Brush、ToolTip相关组件
abstract class CoordLayout<T extends Coord> extends ChartViewGroup {
  T? _props;

  T get props => _props!;
  final ViewPort viewPort = ViewPort.zero();

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  BrushView? _brushView;
  ToolTipView? _tipView;

  CoordLayout(super.context, T props) {
    _props = props;
    layoutParams = props.layoutParams;
  }

  CoordType get coordType => props.coordSystem;

  @override
  void onCreate() {
    super.onCreate();
    if (props.brush != null) {
      _brushView = BrushView(context, this, props.brush!);
      addView(_brushView!);
    }
    var tooltip = findToolTip();
    if (tooltip != null) {
      ToolTip toolTip = ToolTip(show: false);
      _tipView = ToolTipView(context, toolTip);
      addView(_tipView!);
    }
    context.addActionCall(dispatchAction);
    registerCommandHandler();
    props.addListener(_handleCommand);
  }

  @override
  void onDispose() {
    context.removeActionCall(dispatchAction);
    props.removeListener(_handleCommand);
    unregisterCommandHandler();

    _props = null;
    _brushView = null;
    _tipView = null;
    super.onDispose();
  }

  ToolTip? findToolTip() {
    if (props.toolTip != null) {
      return props.toolTip;
    }
    return context.option.toolTip;
  }

  void _handleCommand() {
    onReceiveCommand(props.value);
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    requestLayout();
  }

  @override
  void dispatchDraw(CCanvas canvas) {
    List<ChartView> vl = [];
    for (var child in children) {
      if (child is BrushView || child is ToolTipView) {
        vl.add(child);
      } else {
        drawChild(child, canvas);
      }
    }
    for (var child in vl) {
      drawChild(child, canvas);
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
    canvas.drawRect(boxBound.translate(-left, -top), mPaint);
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

  @override
  bool get freeDrag => props.freeDrag;

  @override
  bool get freeLongPress => props.freeLongPress;
}
