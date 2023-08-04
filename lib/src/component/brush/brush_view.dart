import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///框选
///BrushView 只能在坐标系中出现
///覆盖在单个坐标系的最顶层
class BrushView extends ChartView {
  final CoordLayout coord;
  final Brush brush;
  final List<BrushArea> brushList = [];

  BrushView(this.coord, this.brush) {
    layoutParams = const LayoutParams.matchAll();
  }

  @override
  set layoutParams(LayoutParams p) {
    if (!p.width.isMatch || !p.height.isMatch) {
      throw ChartError("BrushView only support match all");
    }
    super.layoutParams = p;
  }

  final RectGesture _gesture = RectGesture();

  @override
  void onCreate() {
    super.onCreate();
    _initGesture();
  }

  Offset _lastDrag = Offset.zero;

  void _initGesture() {
    _gesture.clear();
    context.removeGesture(_gesture);
    context.addGesture(_gesture);

    _gesture.longPressStart = (e) {
      var offset = toLocalOffset(e.globalPosition);
      _lastDrag = offset;
      onDragStart(offset);
    };
    _gesture.longPressMove = (e) {
      var offset = toLocalOffset(e.globalPosition);
      var dx = offset.dx - _lastDrag.dx;
      var dy = offset.dy - _lastDrag.dy;
      _lastDrag = offset;
      onDragMove(offset, Offset(dx, dy));
    };
    _gesture.longPressEnd = () {
      _lastDrag = Offset.zero;
      onDragEnd();
    };

    _gesture.click = (e) {
      onClick(toLocalOffset(e.globalPosition));
    };
  }

  bool handleAction(ChartAction action) {
    if (!brush.enable) {
      return false;
    }
    if (action is BrushClearAction) {
      if (action.brushId == brush.id) {
        brushList.clear();
        context.dispatchEvent(BrushClearEvent(brush.id, coord.props.coordSystem));
        invalidate();
        return true;
      }
      return false;
    }
    if (action is BrushAction) {
      if (handleActionList(action.actionList) > 0) {
        sendBrushEvent(brushList);
        invalidate();
      }
      return false;
    }
    if (action is BrushEndAction) {
      if (handleActionList(action.actionList) > 0) {
        sendBrushEndEvent(brushList);
        invalidate();
      }
      return false;
    }
    return false;
  }

  int handleActionList(List<BrushActionData> list) {
    int c = 0;
    for (var data in list) {
      if (data.brushId != brush.id) {
        continue;
      }
      if (!brush.supportMulti) {
        brushList.clear();
      }
      brushList.add(BrushArea(data.brushType, data.range));
      c++;
    }
    return c;
  }

  void sendBrushEvent(List<BrushArea> brushList, [bool redraw = true]) {
    if (redraw) {
      invalidate();
    }
    BrushEvent event = BrushEvent(coord.props.coordSystem, brush.id, data: brushList);
    context.dispatchEvent(event);
  }

  void sendBrushEndEvent(List<BrushArea> brushList, [bool redraw = true]) {
    if (redraw) {
      invalidate();
    }
    BrushEndEvent event = BrushEndEvent(coord.props.coordSystem, brush.id, brushList);
    context.dispatchEvent(event);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _gesture.rect = globalBoxBound;
  }

  @override
  void onStart() {
    super.onStart();
    context.addActionCall(handleAction);
  }

  @override
  void onStop() {
    context.removeActionCall(handleAction);
    super.onStop();
  }

  @override
  void onDestroy() {
    brushList.clear();
    super.onDestroy();
  }

  @override
  void onDraw(Canvas canvas) {
    if (!brush.enable) {
      return;
    }
    for (var area in brushList) {
      brush.areaStyle.drawPath(canvas, mPaint, area.path);
      brush.borderStyle?.drawPath(canvas, mPaint, area.path, needSplit: false);
    }
    var ol = _ol;
    if (ol.isNotEmpty) {
      brush.areaStyle.drawPolygonArea(canvas, mPaint, ol);
      brush.borderStyle?.drawPolygon(canvas, mPaint, ol, true);
    }
  }

  ///======手势处理=======
  List<Offset> _ol = [];
  Offset? _first;
  Offset? _last;

  void onClick(Offset offset) {
    if (!brush.enable) {
      return;
    }
    var scroll = coord.getTranslation();
    offset = offset.translate(scroll.dx.abs(), scroll.dy);
    if (brush.removeOnClick && !brush.supportMulti && brushList.isNotEmpty) {
      var first = brushList.first;
      if (!first.path.contains(offset)) {
        brushList.clear();
        invalidate();
        context.dispatchEvent(BrushClearEvent(brush.id, coord.props.coordSystem));
      }
    }
  }

  void onDragStart(Offset offset) {
    var scroll = coord.getTranslation();
    offset = offset.translate(scroll.dx.abs(), scroll.dy);
    _ol.clear();
    _first = null;
    if (!brush.enable) {
      return;
    }
    _first = offset;
  }

  void onDragMove(Offset offset, Offset diff) {
    if (!brush.enable) {
      _ol = [];
      _first = null;
      return;
    }
    var scroll = coord.getTranslation();
    offset = offset.translate(scroll.dx.abs(), scroll.dy);

    var first = _first;
    if (first == null) {
      throw ChartError("状态异常");
    }
    _last = offset;
    if (brush.type != BrushType.polygon) {
      _ol = buildArea(first, offset);
    } else {
      _ol.add(offset);
    }
    List<BrushArea> areaList = List.from(brushList);
    if (_ol.isNotEmpty) {
      areaList.add(BrushArea(brush.type, _ol));
    }
    sendBrushEvent(areaList);
  }

  void onDragEnd() {
    if (!brush.enable) {
      _ol = [];
      _first = null;
      _last = null;
      return;
    }
    var first = _first;
    var last = _last;
    if (first == null || last == null) {
      throw ChartError("状态异常");
    }
    if (brush.type != BrushType.polygon) {
      _ol = buildArea(first, last);
    }
    if (!brush.supportMulti) {
      brushList.clear();
    }
    if (_ol.isNotEmpty) {
      brushList.add(BrushArea(brush.type, _ol));
    }
    sendBrushEndEvent(brushList);
    _ol = [];
    _first = null;
    _last = null;
  }

  List<Offset> buildArea(Offset first, Offset offset) {
    var scroll = coord.getTranslation();
    if (brush.type == BrushType.rect) {
      return [
        first,
        Offset(offset.dx, first.dy),
        offset,
        Offset(first.dx, offset.dy),
      ];
    }

    if (brush.type == BrushType.vertical) {
      return [
        Offset(scroll.dx.abs(), first.dy),
        Offset(scroll.dx.abs() + width, first.dy),
        Offset(scroll.dx.abs() + width, offset.dy),
        Offset(scroll.dx.abs(), offset.dy),
      ];
    }
    if (brush.type == BrushType.horizontal) {
      return [
        Offset(first.dx, height),
        Offset(first.dx, scroll.dy),
        Offset(offset.dx, scroll.dy),
        Offset(offset.dx, height),
      ];
    }
    return [];
  }
}
