import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///负责处理和布局所有的子View
///包括了Brush、ToolTip相关组件
abstract class CoordLayout<T extends Coord> extends ChartViewGroup {
  final T props;
  final ViewPort viewPort = ViewPort.zero();
  late final CoordScale coordScale;

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  BrushView? _brushView;
  ToolTipView? _tipView;

  CoordLayout(this.props) : super() {
    layoutParams = props.layoutParams;
    coordScale = CoordScale(props.id, props.coordSystem, 1, 1);
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
    context.addActionCall(dispatchAction);
    registerCommandHandler();
    props.addListener(_handleCommand);
  }

  void _handleCommand() {
    onReceiveCommand(props.value);
  }

  @override
  void onStop() {
    context.removeActionCall(dispatchAction);
    props.removeListener(_handleCommand);
    unregisterCommandHandler();
    super.onStop();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    requestLayoutSelf();
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
    canvas.drawRect(selfBoxBound, mPaint);
  }

  @override
  bool get enableHover => false;

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

}
