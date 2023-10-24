import 'package:flutter/material.dart';

abstract class Disposable {
  bool _disposeFlag = false;

  bool get isDispose => _disposeFlag;

  @mustCallSuper
  void dispose() {
    _disposeFlag = true;
  }
}
