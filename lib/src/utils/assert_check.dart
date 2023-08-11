import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

void assertCheck(bool value, {String? msg}) {
  if (!value) {
    throw FlutterError(msg ?? "断言错误");
  }
}
void checkDataType(dynamic data){
  if(data is String || data is DateTime || data is num){
    return;
  }
  throw ChartError('只接受String DateTime num');
}