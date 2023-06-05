import 'package:flutter/animation.dart';
import 'package:uuid/uuid.dart';

import 'animator_props.dart';

///全局的动画管理者
class AnimationManager {
  static final AnimationManager _instance = AnimationManager._internal();

  static AnimationManager get instance => _instance;

  final Uuid _uuid = const Uuid();

  AnimationManager._internal();

  factory AnimationManager() => _instance;

  ///存储已经创建的控制器
  final Map<String, AnimationController> _map = {};

  AnimationController bounded(TickerProvider provider, AnimatorProps props, [String? key]) {
    AnimationController c = AnimationController(
      vsync: provider,
      duration: props.duration,
      reverseDuration: props.reverseDuration,
      lowerBound: props.lowerBound,
      upperBound: props.upperBound,
      animationBehavior: props.behavior,
    );
    key ??= _uuid.v4().replaceAll('-', '');
    if (_map.containsKey(key)) {
      _map.remove(key)?.dispose();
    }
    _map[key] = c;
    return c;
  }

  AnimationController unbounded(TickerProvider provider, [String? key]) {
    AnimationController c = AnimationController.unbounded(vsync: provider, duration: const Duration(days: 999));
    key ??= _uuid.v4().replaceAll('-', '');
    if (_map.containsKey(key)) {
      _map.remove(key)?.dispose();
    }
    _map[key] = c;
    return c;
  }

  void remove(AnimationController c, [bool dispose = true]) {
    _map.removeWhere((key, value) => value == c);
    if (dispose) {
      try{
        c.dispose();
      }catch(_){}
    }
  }

  void removeByKey(String key, [bool dispose = true]) {
    AnimationController? c = _map.remove(key);
    if (c == null) {
      return;
    }
    if (dispose) {
      try{
        c.dispose();
      }catch(_){}
    }
  }

  void dispose() {
    _map.forEach((key, value) {
      try{
        value.dispose();
      }catch(_){}
    });
    _map.clear();
  }
}
