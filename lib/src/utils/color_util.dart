import 'dart:math';

import 'package:flutter/material.dart';

Random _random = Random();

Color randomColor() {
  int r = _random.nextInt(145) + 50;
  int g = _random.nextInt(135) + 50;
  int b = _random.nextInt(125) + 50;

  return Color.fromARGB(255, r, g, b);
}

extension ColorUtil on Color {
  static Color? fromStringRepresentation(String colorValue) {
    if (colorValue.startsWith("#")) {
      return fromHex(colorValue);
    } else if (colorValue.startsWith("rgb(")) {
      return fromRgbString(colorValue);
    } else if (colorValue.startsWith("rgba(")) {
      return fromRgbaString(colorValue);
    } else if (colorValue.startsWith("hls(")) {
      return fromHlsString(colorValue);
    } else if (colorValue.startsWith("hlsa(")) {
      return fromHlsaString(colorValue);
    }
    return null;
  }

  static Color? fromHex(String? hexString) {
    if (hexString == null) {
      return null;
    }

    hexString = hexString.trim();
    if (hexString.length == 4) {
      // convert for example #f00 to #ff0000
      hexString = "#" + (hexString[1] * 2) + (hexString[2] * 2) + (hexString[3] * 2);
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color? fromRgbString(String? rgbString) {
    if (rgbString == null) {
      return null;
    }

    rgbString = rgbString.trim();
    var rgbValues =
        rgbString.substring(4, rgbString.length - 1).split(",").map((rbgValue) => int.parse(rbgValue.trim())).toList();
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromRgbaString(String? rgbaString) {
    if (rgbaString == null) {
      return null;
    }

    rgbaString = rgbaString.trim();
    var rgbaValues =
        rgbaString.substring(5, rgbaString.length - 1).split(",").map((rbgValue) => rbgValue.trim()).toList();
    return Color.fromRGBO(
        int.parse(rgbaValues[0]), int.parse(rgbaValues[1]), int.parse(rgbaValues[2]), double.parse(rgbaValues[3]));
  }

  static Color? fromHlsString(String? hlsString) {
    if (hlsString == null) {
      return null;
    }

    hlsString = hlsString.trim();
    var hlsValues = hlsString
        .substring(4, hlsString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbValues = _hslToRgb(hlsValues[0], hlsValues[1], hlsValues[2]);
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromHlsaString(String? hlsaString) {
    if (hlsaString == null) {
      return null;
    }

    hlsaString = hlsaString.trim();
    var hlsaValues = hlsaString
        .substring(5, hlsaString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbaValues = _hslToRgb(hlsaValues[0], hlsaValues[1], hlsaValues[2]);
    return Color.fromRGBO(rgbaValues[0], rgbaValues[1], rgbaValues[2], hlsaValues[3]);
  }

  static List<int> _hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }
    var rgb = [_to255(r), _to255(g), _to255(b)];
    return rgb;
  }

  static int _to255(double v) {
    return min(255, (256 * v).round());
  }

  /// Helper method that converts hue to rgb
  static double _hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  static Color fromHSL(num h, double s, double l) {
    return HSLColor.fromAHSL(1, h.toDouble(), s, l.toDouble()).toColor();
  }
}
