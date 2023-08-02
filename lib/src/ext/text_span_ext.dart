import 'package:flutter/painting.dart';
import '../model/data.dart';

extension TextSpanExt on TextSpan {
  DynamicText toText() {
    return DynamicText(this);
  }
}