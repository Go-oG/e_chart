import 'package:flutter/material.dart';

void assertCheck(bool value, {String? msg}) {
  if (!value) {
    throw FlutterError(msg ?? "断言错误");
  }
}
