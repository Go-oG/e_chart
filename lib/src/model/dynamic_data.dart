import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:chart_xutil/chart_xutil.dart';

///动态数据(只接受字符串 数字 时间类型的数据)
class DynamicData {
  dynamic data;

  DynamicData(this.data) {
    if (data is! String && data is! DateTime && data is! num) {
      throw FlutterError('只能是 String、DateTime、num CurrentType:${data.runtimeType}');
    }
  }

  DynamicData change(dynamic data) {
    if (data is! String && data is! DateTime && data is! num) {
      throw FlutterError('只能是 String DateTime num CurrentType:${data.runtimeType}');
    }
    this.data = data;
    return this;
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

  String getText([int fractionDigits = 3, Fun2<DateTime, String>? timeFormatter]) {
    if (isString) {
      return '$data';
    }
    if (isNum) {
      return formatNumber(data as num,1);
    }

    var time = data as DateTime;
    if (timeFormatter != null) {
      return timeFormatter.call(time);
    }
    return '${padLeft(time.month, 2, '0')}-${padLeft(time.day, 2, '0')}';
  }

  @override
  String toString() {
    if (isString) {
      return 'String: $data';
    }
    if (isNum) {
      return 'Number:${(data as num).toStringAsFixed(1)}';
    }

    var time = data as DateTime;
    return 'Time:${time.year}-${padLeft(time.month, 2, '0')}-${padLeft(time.day, 2, '0')} '
        '${padLeft(time.hour, 2, '0')}:${padLeft(time.minute, 2, '0')}:${padLeft(time.second, 2, '0')}';
  }
}
