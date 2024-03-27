import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///框选
///BrushView 只能在坐标系中出现
///覆盖在单个坐标系的最顶层(比TooltipView 低)
class BrushView extends GestureView {
  CoordLayout? _coord;
  CoordLayout get coord => _coord!;
  Brush? _brush;

  Brush get brush => _brush!;
  List<BrushArea> _brushList = [];
  late final BrushEndEvent _endEvent;
  late final BrushStartEvent _startEvent;
  late final BrushUpdateEvent _updateEvent;

  BrushView(super.context, this._coord, this._brush) {
    layoutParams = LayoutParams.matchAll();
    _endEvent = BrushEndEvent(coord.props.id, coord.id, coord.props.coordSystem, brush.id, []);
    _startEvent = BrushStartEvent(coord.props.id, coord.id, coord.props.coordSystem, brush.id, []);
    _updateEvent = BrushUpdateEvent(coord.props.id, coord.id, coord.props.coordSystem, brush.id, []);
  }

  @override
  set layoutParams(LayoutParams p) {
    if (!p.width.isMatch || !p.height.isMatch) {
      throw ChartError("BrushView only support match all");
    }
    super.layoutParams = p;
  }

  @override
  void onCreate() {
    super.onCreate();
    brush.addListener(handleBrushCommand);
    context.addActionCall(_handleAction);
  }

  void handleBrushCommand() {
    var c = brush.value;
    if (c.code == Command.showBrush.code || c.code == Command.hideBrush.code) {
      requestDraw();
      return;
    }
    if (c.code == Command.clearBrush.code || c.code == Command.configChange.code) {
      _brushList = [];
      requestDraw();
      return;
    }
  }

  @override
  bool get enableLongPress => true;

  @override
  bool get enableClick => true;

  @override
  bool get enableScale => false;

  @override
  bool get enableHover => false;

  bool _handleAction(ChartAction action) {
    if (!brush.enable) {
      return false;
    }
    if (action is BrushClearAction) {
      if (action.brushId == brush.id) {
        _brushList = [];
        context.dispatchEvent(_endEvent);
        requestDraw();
        return true;
      }
      return false;
    }
    if (action is BrushAction) {
      if (_handleActionList(action.actionList) > 0) {
        _sendBrushEvent(_brushList);
        requestDraw();
      }
      return false;
    }
    if (action is BrushEndAction) {
      if (_handleActionList(action.actionList) > 0) {
        _sendBrushEndEvent(_brushList);
        requestDraw();
      }
      return false;
    }
    return false;
  }

  int _handleActionList(List<BrushActionData> list) {
    int c = 0;
    for (var data in list) {
      if (data.brushId != brush.id) {
        continue;
      }
      if (!brush.supportMulti) {
        _brushList.clear();
      }
      _brushList.add(BrushArea(data.brushType, data.range));
      c++;
    }
    return c;
  }

  void _sendBrushEvent(List<BrushArea> brushList, [bool redraw = true]) {
    _updateEvent.areas = brushList;
    context.dispatchEvent(_updateEvent);
    if (redraw) {
      requestDraw();
    }
  }

  void _sendBrushEndEvent(List<BrushArea> brushList, [bool redraw = true]) {
    context.dispatchEvent(_endEvent);
    if (redraw) {
      requestDraw();
    }
  }

  @override
  void onDispose() {
    context.removeActionCall(_handleAction);
    brush.removeListener(handleBrushCommand);
    _coord = null;
    _brush = null;
    _brushList = [];
    super.onDispose();
  }

  @override
  void onDraw(CCanvas canvas) {
    if (!brush.enable) {
      return;
    }
    for (var area in _brushList) {
      brush.areaStyle.drawPath(canvas, mPaint, area.path);
      brush.borderStyle?.drawPath(canvas, mPaint, area.path);
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

  @override
  void onClick(Offset offset) {
    if (!brush.enable) {
      return;
    }
    offset = offset.translate(scrollX, scrollY);
    if (brush.removeOnClick && !brush.supportMulti && _brushList.isNotEmpty) {
      var first = _brushList.first;
      if (!first.path.contains(offset)) {
        _brushList = [];
        requestDraw();
        context.dispatchEvent(_endEvent);
      }
    }
  }

  @override
  void onDragStart(Offset offset) {
    offset = offset.translate(scrollX, scrollY);
    _ol.clear();
    _first = null;
    if (!brush.enable) {
      return;
    }
    _first = offset;
    context.dispatchEvent(_startEvent);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (!brush.enable) {
      _ol = [];
      _first = null;
      return;
    }
    offset = offset.translate(scrollX, scrollY);

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
    List<BrushArea> areaList = List.from(_brushList);
    if (_ol.isNotEmpty) {
      areaList.add(BrushArea(brush.type, _ol));
    }
    _sendBrushEvent(areaList);
  }

  @override
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
      _brushList = [];
    }
    if (_ol.isNotEmpty) {
      _brushList.add(BrushArea(brush.type, _ol));
    }
    _sendBrushEndEvent(_brushList);
    _ol = [];
    _first = null;
    _last = null;
  }

  List<Offset> buildArea(Offset first, Offset offset) {
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
        Offset(scrollX, first.dy),
        Offset(scrollX + width, first.dy),
        Offset(scrollX + width, offset.dy),
        Offset(scrollX, offset.dy),
      ];
    }
    if (brush.type == BrushType.horizontal) {
      return [
        Offset(first.dx, height),
        Offset(first.dx, scrollY),
        Offset(offset.dx, scrollY),
        Offset(offset.dx, height),
      ];
    }
    return [];
  }
}
