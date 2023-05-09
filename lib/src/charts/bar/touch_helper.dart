import 'package:flutter/material.dart';

import '../../ext/int_ext.dart';
import '../../gesture/gesture_event.dart';
import 'layout/single _node.dart';
import 'layout_helper.dart';

/// 用于辅助处理用户触摸相关的事件
class TouchHelper {
  static const int draw = 1;
  static const int drawAndAnimator = 2;
  final ValueNotifier<IntWrap> notifier;
  final LayoutHelper layoutHelper;

  Rect? _hoverRect; //记录跟随鼠标和手势运动的区域
  SingleNode? _selectNode; //记录当前选择的单个节点

  TouchHelper(this.notifier, this.layoutHelper);

  Rect? get hoverRect => _hoverRect;

  SingleNode? get selectNode => _selectNode;

  bool dispatchTouchEvent(MotionEvent event) {
    _handleUserEvent(event);
    return onTouchEvent(event);
  }

  bool onTouchEvent(MotionEvent event) {
    return false;
  }

  void _handleUserEvent(MotionEvent event) {
    // int action = event.action;
    // Offset offset = event.localPosition;
    // bool b1 = action == MotionEvent.actionMove || action == MotionEvent.actionMouseEnter || action == MotionEvent.actionMouseHover;
    // bool b2 = action == MotionEvent.actionCancel || action == MotionEvent.actionUp || action == MotionEvent.actionMouseExit;
    // if (b1) {
    //   _handleHoverEnter(offset);
    // } else if (b2) {
    //   _handleHoverExit(offset);
    // }
  }
  //
  // void _handleHoverEnter(Offset offset) {
  //   SingleNode? singleNode;
  //   for (var element in layoutHelper.groupElementList) {
  //     for (var e2 in element.nodeList) {
  //       for (var e3 in e2.nodeList) {
  //         if (e3.contains(offset)) {
  //           singleNode = e3;
  //           break;
  //         }
  //       }
  //       if (singleNode != null) {
  //         break;
  //       }
  //     }
  //     if (singleNode != null) {
  //       break;
  //     }
  //   }
  //
  //   Rect? hoverRect;
  //   if (singleNode == null) {
  //     for (var element in layoutHelper.groupElementList) {
  //       for (var e2 in element.nodeList) {
  //         if (e2.rootPositionRect.contains(offset)) {
  //           hoverRect = e2.rootPositionRect;
  //           break;
  //         }
  //       }
  //       if (hoverRect != null) {
  //         break;
  //       }
  //     }
  //   } else {
  //     hoverRect = singleNode.parent.rootPositionRect;
  //   }
  //   final bool hasChange = singleNode != _selectNode;
  //   final bool rectChange = hoverRect != _hoverRect;
  //   if (rectChange) {
  //     _hoverRect = hoverRect;
  //   }
  //
  //   if (hasChange) {
  //     for (var element in layoutHelper.barGroupElementList) {
  //       for (var e2 in element.nodeList) {
  //         for (var e3 in e2.nodeList) {
  //           e3.onHover(
  //             e3.contains(offset),
  //             singleNode != null,
  //             singleNode != null && e3.group == singleNode.group,
  //           );
  //         }
  //       }
  //     }
  //     _selectNode = singleNode;
  //   }
  //
  //   if (hasChange) {
  //     notifier.value = drawAndAnimator.wrap();
  //   } else if (rectChange) {
  //     notifier.value = draw.wrap();
  //   }
  // }
  //
  // void _handleHoverExit(Offset offset) {
  //   if (_hoverRect == null && _selectNode == null) {
  //     return;
  //   }
  //   _hoverRect = null;
  //   _selectNode = null;
  //   for (var element in layoutHelper.barGroupElementList) {
  //     for (var e2 in element.nodeList) {
  //       for (var e3 in e2.nodeList) {
  //         e3.onHover(false, false, false);
  //       }
  //     }
  //   }
  //   notifier.value = drawAndAnimator.wrap();
  // }
  //
  void clear() {
    // _hoverRect = null;
    // _selectNode = null;
    // for (var element in layoutHelper.groupElementList) {
    //   for (var e2 in element.nodeList) {
    //     for (var e3 in e2.nodeList) {
    //       e3.onHover(false, false, false);
    //     }
    //   }
    // }
  }

}
