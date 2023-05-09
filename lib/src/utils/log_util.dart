
import 'package:flutter/widgets.dart';

bool logEnable=true;

logPrint(String s){
  if(logEnable){
    debugPrint(s);
  }
}