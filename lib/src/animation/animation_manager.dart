import 'package:flutter/animation.dart';
import 'package:uuid/uuid.dart';

import '../utils/log_util.dart';
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

  AnimationController bounded(TickerProvider provider, AnimatorProps props, {String? key,bool useUpdate=false}) {
    //_collate();
    AnimationController c = AnimationController(
      vsync: provider,
      duration:useUpdate?props.updateDuration: props.duration,
      reverseDuration: useUpdate?props.updateDuration: props.duration,
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

  AnimationController unbounded(TickerProvider provider, {String? key}) {
    _collate();
    AnimationController c = AnimationController.unbounded(vsync: provider, duration: const Duration(days: 999));
    key ??= _uuid.v4().replaceAll('-', '');
    if (_map.containsKey(key)) {
      _map.remove(key)?.dispose();
    }
    _map[key] = c;
    return c;
  }

  int _count = 0;

  void _collate() {
    _count++;
    if (_count < 30) {
      return;
    }
    _count = 0;
    try {
      _map.removeWhere((key, value) => value.isCompleted || value.isDismissed);
    } catch (e) {
      logPrint('$e');
    }
  }

  void remove(AnimationController c, [bool dispose = true]) {
    _map.removeWhere((key, value) => value == c);
    if (dispose) {
      try {
        c.dispose();
      } catch (_) {}
    }
  }

  void removeByKey(String key, [bool dispose = true]) {
    AnimationController? c = _map.remove(key);
    if (c == null) {
      return;
    }
    if (dispose) {
      try {
        c.dispose();
      } catch (_) {}
    }
  }

  void updateTickerProvider(TickerProvider provider) {
    _map.forEach((key, value) {
      value.resync(provider);
    });
  }

  void dispose() {
    _map.forEach((key, value) {
      try {
        value.dispose();
      } catch (_) {}
    });
    _map.clear();
  }
}
