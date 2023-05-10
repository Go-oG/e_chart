import 'dart:io';

import 'package:flutter/material.dart';
import '../chart.dart';
import '../coord/circle_coord_layout.dart';
import '../coord/rect_coord_layout.dart';
import '../gesture/gesture_dispatcher.dart';
import '../model/enums/drag_type.dart';
import '../model/enums/scale_type.dart';
import 'context.dart';
import 'view.dart';
import 'view_group.dart';

class Chart extends StatefulWidget {
  final ChartConfig config;

  const Chart(this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartState();
  }
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  late MultiRender render;
  bool hasInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (hasInit) {
      init();
    } else {
      hasInit = true;
    }
  }

  void init() {
    render = MultiRender(widget.config, this);
  }

  @override
  void dispose() {
    render.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChartConfig config = widget.config;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildPainter(config),
      ),
    );
  }

  Widget _buildPainter(ChartConfig config) {
    GestureDispatcher dispatcher = render.context.gestureDispatcher;

    void Function(LongPressStartDetails)? lps;
    void Function(LongPressMoveUpdateDetails)? lpm;
    void Function(LongPressEndDetails)? lpe;
    VoidCallback? lpc;
    if (config.dragType == DragType.longPress) {
      lps = dispatcher.onLongPressStart;
      lpm = dispatcher.onLongPressMove;
      lpe = dispatcher.onLongPressEnd;
      lpc = dispatcher.onLongPressCancel;
    }
    void Function(TapDownDetails)? dtd;
    VoidCallback? dtc;
    if (config.scaleType == ScaleType.doubleTap) {
      dtd = dispatcher.onDoubleTapDown;
      dtc = dispatcher.onDoubleTapCancel;
    }
    void Function(ScaleStartDetails)? ss;
    void Function(ScaleUpdateDetails)? su;
    void Function(ScaleEndDetails)? se;
    if (config.dragType == DragType.drag || config.scaleType == ScaleType.scale) {
      ss = dispatcher.onScaleStart;
      su = dispatcher.onScaleUpdate;
      se = dispatcher.onScaleEnd;
    }

    Widget ges = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: dispatcher.onTapDown,
      onTapUp: dispatcher.onTapUp,
      onTapCancel: dispatcher.onTapCancel,
      onDoubleTapDown: dtd,
      onDoubleTapCancel: dtc,
      onLongPressStart: lps,
      onLongPressMoveUpdate: lpm,
      onLongPressEnd: lpe,
      onLongPressCancel: lpc,
      onScaleStart: ss,
      onScaleUpdate: su,
      onScaleEnd: se,
      child: RepaintBoundary(
        child: CustomPaint(painter: render),
      ),
    );
    bool isPhone = Platform.isIOS || Platform.isAndroid;

    if (isPhone) {
      return ges;
    }
    return MouseRegion(
      onEnter: dispatcher.onHoverStart,
      onExit: dispatcher.onHoverEnd,
      onHover: dispatcher.onHoverMove,
      opaque: false,
      child: ges,
    );
  }
}

/// 渲染的基类，支持多个Render 同时渲染
class MultiRender extends ChangeNotifier implements CustomPainter, ViewParent {
  late final Context context;
  bool _firstDraw = true;
  bool _layoutFlag = false;
  bool _drawing = false;

  MultiRender(ChartConfig config, TickerProvider tickerProvider) {
    context = Context(
      config,
      tickerProvider,
      GestureDispatcher(),
      this,
    );
    context.init();
  }

  Size? _oldSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    if (_oldSize == null || size != _oldSize) {
      _layoutFlag = true;
      _oldSize = size;
      List<View> vl = [...context.renderList];

      //测量toolTip相关的
      //if (context.toolTipNode != null) {
        vl.add(context.toolTipNode);
     // }

      for (var element in vl) {
        element.measure(size.width, size.height);
      }

      for (var element in vl) {
        if (element is RectCoordLayout) {
          double leftMargin = element.props.leftMargin.convert(size.width);
          double topMargin = element.props.topMargin.convert(size.height);
          element.layout(leftMargin, topMargin, leftMargin + element.boundRect.width, topMargin + element.boundRect.height);
        } else if (element is CircleCoordLayout) {
          double centerX = element.props.center[0].convert(size.width);
          double centerY = element.props.center[1].convert(size.height);
          double radius = element.boundRect.width / 2;
          element.layout(centerX - radius, centerY - radius, centerX + radius, centerY + radius);
        } else {
          element.layout(0, 0, element.boundRect.width, element.boundRect.height);
        }
      }

      _layoutFlag = false;
    }
    eachRender(canvas, size);
  }

  void eachRender(Canvas canvas, Size size) {
    if (_drawing) {
      return;
    }
    _drawing = true;
    if (_firstDraw) {
      _firstDraw = false;
    }
    for (var element in context.renderList) {
      element.draw(canvas);
    }
    _drawing = false;
  }

  @override
  bool? hitTest(Offset position) {
    return true;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    for (var element in context.renderList) {
      if (element.isDirty) {
        return true;
      }
    }
    return false;
  }

  void updateUI({bool animator = false}) {
    //如果当前正在绘制则丢弃
    if (_drawing || _layoutFlag) {
      debugPrint('阻挡绘制 $_drawing  $_layoutFlag');
      return;
    }
    notifyListeners();
  }

  @override
  void changeChildToFront(View child) {}

  @override
  void clearChildFocus(View child) {}

  @override
  void parentInvalidate({bool animator = false}) {
    updateUI(animator: animator);
  }

  @override
  void requestLayout() {
    if (_layoutFlag) {
      return;
    }
    _oldSize = null;
    updateUI();
  }

  void destroy() {
    context.destroy();
  }

  @override
  Rect getGlobalAreaBounds() {
    if (_oldSize == null) {
      return Rect.zero;
    }
    return Rect.fromLTWH(0, 0, _oldSize!.width, _oldSize!.height);
  }
}
