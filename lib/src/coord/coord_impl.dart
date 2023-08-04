import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///负责处理和布局所有的子View
///包括了Brush、ToolTip相关组件
abstract class CoordLayout<T extends Coord> extends ChartViewGroup {
  final T props;
  final RectGesture _gesture = RectGesture();
  double scaleXFactor = 1;
  double scaleYFactor = 1;
  double scrollXOffset = 0;
  double scrollYOffset = 0;

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  BrushView? _brushView;
  ToolTipView? _tipView;

  CoordLayout(this.props) {
    if (props.brush != null) {
      _brushView = onCreateBrushView(props.brush!);
      if (_brushView != null) {
        addView(_brushView!);
      }
    }
    testTip();
  }

  BrushView? onCreateBrushView(Brush brush) {
    return BrushView(this, props.brush!);
  }

  void testTip() {
    ToolTip toolTip = ToolTip(show: true);
    _tipView = ToolTipView(toolTip);
    var menu = ToolTipMenu([], title: "Test".toText());
    for (int i = 0; i < 50; i++) {
      menu.itemList.add(MenuItem(
        "Item$i".toText(),
        LabelStyle(),
        symbol: CircleSymbol.normal(outerRadius: 8, color: randomColor()),
        desc: "Desc:$i".toText(),
      ));
    }
    _tipView?.updateView(menu);
    addView(_tipView!);
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
    forceLayout = true;
    layout(left, top, right, bottom);
  }

  @mustCallSuper
  @override
  void onLayoutEnd() {
    super.onLayoutEnd();
    _gesture.rect = globalBoxBound;
  }

  @override
  void dispatchDraw(Canvas canvas) {
    List<ChartView> vl = [];
    for (var child in children) {
      int count = canvas.getSaveCount();
      if (child is BrushView || child is ToolTipView) {
        vl.add(child);
      } else {
        drawChild(child, canvas);
      }
      if (canvas.getSaveCount() != count) {
        throw FlutterError('you should call canvas.restore when after call canvas.save');
      }
    }
    for (var child in vl) {
      int count = canvas.getSaveCount();
      drawChild(child, canvas);
      if (canvas.getSaveCount() != count) {
        throw FlutterError('you should call canvas.restore when after call canvas.save');
      }
    }
  }

  @override
  void onDrawBackground(Canvas canvas) {
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
  bool get enableHover => props.enableHover;

  @override
  bool get enableDrag => props.enableDrag;

  @override
  bool get enableClick => props.enableClick;

  @override
  bool get enableScale => props.enableScale;

  Offset getScaleFactor() {
    return Offset(scaleXFactor, scaleYFactor);
  }

  Offset getTranslation() {
    return Offset(scrollXOffset, scrollYOffset);
  }

  ///获取最大能够平移的值
  Offset getMaxTranslation() {
    return Offset.zero;
  }

  ///返回不包含BrushView的子视图列表
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
