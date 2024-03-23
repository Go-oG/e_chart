import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///坐标系
abstract class Coord extends ChartNotifier<Command> {
  late final String id;
  bool show;
  Color? backgroundColor;

  ///数据框选配置
  Brush? brush;

  ///ToolTip
  ToolTip? toolTip;

  LayoutParams layoutParams = LayoutParams.matchAll();

  bool freeDrag;
  bool freeLongPress;

  Coord({
    this.show = true,
    String? id,
    this.brush,
    this.toolTip,
    this.backgroundColor,
    this.freeDrag = false,
    this.freeLongPress = false,
    LayoutParams? layoutParams,
  }) : super(Command.none) {
    if (layoutParams != null) {
      this.layoutParams = layoutParams;
    }
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  CoordType get coordSystem;

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifyCoordConfigChange() {
    value = Command.configChange;
  }

  CoordLayout? toCoord(Context context) {
    return null;
  }
}

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

  List<dynamic> collectChildDimData(AxisDim dim) {
    List<dynamic> list = [];
    for (var child in children) {
      if (child is! CoordChild) {
        continue;
      }
      var c = child as CoordChild;
      var ex = c.getAxisExtreme(coordType, dim);
      list.addAll(ex);
    }
    return list;
  }

  List<CoordChild> getCoordChildList() {
    List<CoordChild> list = [];
    for (var child in children) {
      if (child is CoordChild) {
        list.add(child as CoordChild);
      }
    }
    return list;
  }

  @override
  bool get freeDrag => props.freeDrag;

  @override
  bool get freeLongPress => props.freeLongPress;
}

abstract class CircleCoordLayout<T extends CircleCoord> extends CoordLayout<T> {
  CircleCoordLayout(super.context, super.props);

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    double w = widthSpec.size;
    double h = heightSpec.size;
    double d = props.radius.last.convert(min(w, h));
    return Size(d, d);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }
}

abstract class CircleCoord extends Coord {
  List<SNumber> center;
  List<SNumber> radius;

  CircleCoord({
    this.radius = const [SNumber.zero, SNumber.percent(40)],
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.brush,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
  });
}