import 'package:flutter/material.dart';
import 'package:xutil/xutil.dart';

///动态数据(只接受字符串 数字 时间类型的数据)
class DynamicData {
  final dynamic data;

  DynamicData(this.data) {
    if (data is! String && data is! DateTime && data is! num) {
      throw FlutterError('只能是 String DateTime num');
    }
  }

  bool get isString {
    return data is String;
  }

  bool get isDate {
    return data is DateTime;
  }

  bool get isNum {
    return data is num;
  }

  @override
  String toString() {
    if (isString) {
      return data as String;
    }
    if (isNum) {
      return (data as num).toStringAsFixed(1);
    }
    var time = data as DateTime;
    return '${time.year}-${padLeft(time.month, 2, '0')}-${padLeft(time.day, 2, '0')} '
        '${padLeft(time.hour, 2, '0')}:${padLeft(time.minute, 2, '0')}:${padLeft(time.second, 2, '0')}';
  }
}
