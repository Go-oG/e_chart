import 'dart:ui';

import 'package:xchart/src/component/tooltip/tool_tip.dart';
import 'package:xchart/src/component/tooltip/tool_tip_listener.dart';
import 'package:xchart/src/gesture/chart_gesture.dart';

import '../../core/view.dart';

///整个图表只有一个
class ToolTipNode extends View {
  final RectGesture _gesture = RectGesture();
  final Map<ToolTip, Set<ToolTipListener>> _listenerMap = {};

//  final PublishSubject<Offset?> _publishSubject = PublishSubject();

  ToolTipNode(){
    // _publishSubject.stream.listen((event) {
    //   if(_position==event){return;}
    //   _position=event;
    //   invalidate();
    // });
  }

  ///记录当前图表的位置
  Offset? _position;

  @override
  void onAttach() {
    super.onAttach();
    _init();
  }

  void _init() {
    _gesture.clear();
    _gesture.hoverStart = (e) {
      _handleGesture(e.globalPosition, true);
    };
    _gesture.hoverMove = (e) {
      _handleGesture(e.globalPosition);
    };
    _gesture.hoverEnd = (e) {
      _handleGesture(null);
    };
    _gesture.clickDown = (e) {
      _handleGesture(e.globalPosition, true);
    };
    _gesture.clickCancel = () {
      _handleGesture(null);
    };
  }

  void _handleGesture(Offset? globalOffset, [bool first = false]) {
    if (globalOffset == null) {
      if (_position == null) {
        return;
      }
       _position=null;
      return;
    }

  }

  @override
  void onDetach() {
    _gesture.clear();
    super.onDetach();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _gesture.rect = globalAreaBound;
  }

  @override
  void onDraw(Canvas canvas) {
    if (_position == null) {
      return;
    }
  }

  void add(ToolTipListener listener) {
    ToolTip? tip = listener.getToolTip();
    if (tip == null) {
      return;
    }
    Set<ToolTipListener> set = _listenerMap[tip] ?? {};
    set.add(listener);
    _listenerMap[tip] = set;
  }

  void remove(ToolTipListener listener) {
    _listenerMap.forEach((key, value) {
      value.remove(listener);
    });
  }

  void removeAll() {
    _listenerMap.clear();
  }
}
