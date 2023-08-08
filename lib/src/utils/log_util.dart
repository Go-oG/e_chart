import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stack_trace/stack_trace.dart';

class Logger {
  static const _topLeftCorner = '┌';
  static const _bottomLeftCorner = '└';
  static const _middleCorner = '├';
  static const _verticalLine = '│';
  static const _doubleDivider = '─';
  static const _encoder = JsonEncoder.withIndent('\t');

  Logger._();

  ///匹配英文字符
  static final englishRegex = RegExp('[\x20-\x7E\\\\]');

  static LogConfig _config = LogConfig(kDebugMode);

  static void init(LogConfig config) {
    _config = config;
  }

  static void v(dynamic content, [String? tag]) {
    _printLog(Level.V, _config.getVerbaseColor(), tag, content, StackTrace.current);
  }

  static void d(dynamic content, [String? tag]) {
    _printLog(Level.D, _config.getDebugColor(), tag, content, StackTrace.current);
  }

  static void i(dynamic content, [String? tag]) {
    _printLog(Level.I, _config.getInfoColor(), tag, content, StackTrace.current);
  }

  static void w(dynamic content, [String? tag]) {
    _printLog(Level.W, _config.getWarningColor(), tag, content, StackTrace.current);
  }

  static void e(dynamic content, [String? tag]) {
    _printLog(Level.E, _config.getErrorColor(), tag, content, StackTrace.current);
  }

  static void _printLog(Level level, LogColor color, String? tag, dynamic content, StackTrace stackTrace) {
    if (!_config.enablePrint) {
      return;
    }
    if (_config.filter != null) {
      if (_config.filter!.filter(level, content, tag)) {
        return;
      }
    }

    List<String> list = _handleLog(_stringifyMessage(content), tag, stackTrace);
    for (var s in list) {
      print("${color.getStrPre()}$s${LogColor.ansiDefault}");
    }
  }

  //转为字符串
  static String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      return _encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  //生成对应的行数据
  static List<String> _handleLog(String log, String? tag, StackTrace stackTrace) {
    List<String> contentList = _splitLargeLog(log, _config.lineMaxLength); //日志数据
    List<String> stackTraceList = _getStackInfo(stackTrace, _config.staticOffset, _config.methodCount); //帧栈数据

    //计算分割线的宽度
    int diverLength = 0;
    for (var element in contentList) {
      if (element.length > diverLength) {
        diverLength = element.length;
      }
    }
    for (var element in stackTraceList) {
      if (element.length > diverLength) {
        diverLength = element.length;
      }
    }
    diverLength += 4;
    if (diverLength > _config.lineMaxLength + 4) {
      diverLength = _config.lineMaxLength + 4;
    }

    //数据拼接
    List<String> resultList = List.empty(growable: true);
    //临时处理字符
    StringBuffer buffer = StringBuffer(_topLeftCorner);

    //添加顶部分割线
    for (int i = 0; i < diverLength; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    buffer.clear();

    //处理 Tag
    if (tag != null && tag.isNotEmpty) {
      resultList.add("${_verticalLine}TAG: $tag");
      buffer.write(_middleCorner);
      for (int i = 0; i < diverLength; i++) {
        buffer.write('─');
      }
      resultList.add(buffer.toString());
      buffer.clear();
    }

    //添加帧栈内容
    if (stackTraceList.isNotEmpty) {
      for (var value in stackTraceList) {
        resultList.add(_verticalLine + value);
      }
      //添加内容和帧栈之间的分割线
      buffer.write(_middleCorner);
      for (int i = 0; i < diverLength; i++) {
        buffer.write('─');
      }
      resultList.add(buffer.toString());
      buffer.clear();
    }

    //添加日志内容和实际的行分割
    for (var s in contentList) {
      resultList.add("$_verticalLine $s");
    }
    //添加底部分割线
    buffer.write(_bottomLeftCorner);
    for (int i = 0; i < diverLength; i++) {
      buffer.write(_doubleDivider);
    }
    resultList.add(buffer.toString());
    return resultList;
  }

  //解析调用栈并生成对应样式字符串列表
  static List<String> _getStackInfo(StackTrace trace, int methodOffset, int methodCount) {
    if (methodOffset < 0) {
      methodOffset = 0;
    }
    if (methodCount <= 0) {
      methodCount = 1;
    }
    var chain = Chain.forTrace(trace);
    int offset = methodOffset;
    List<Frame> frameList = [];
    for (var value in chain.traces) {
      for (var v2 in value.frames) {
        //过滤掉自身的
        if (v2.location.contains('log_util.dart')) {
          continue;
        }
        if (offset <= 0) {
          frameList.add(v2);
        }
        offset--;
        if (frameList.length >= methodCount) {
          break;
        }
      }
      if (frameList.length >= methodCount) {
        break;
      }
    }
    List<String> resultList = [];
    int tabCount = 0;

    for (int i = 0; i < frameList.length; i++) {
      var element = frameList[i];
      String line = element.library;
      if (element.line != null) {
        line += ' ${element.line}';
      }
      String s;
      if (element.member != null) {
        s = "${element.member}($line)";
      } else {
        s = line;
      }

      for (int j = 0; j < tabCount; j++) {
        s = " $s"; //这里没用\t 是避免多个\t造成的间距过大
      }
      resultList.add(s.replaceAll("\n", ''));
      tabCount++;
    }
    return resultList;
  }

  //分割日志
  static List<String> _splitLargeLog(String log, int lineMax) {
    List<String> lineList = List.empty(growable: true); //存储分割后处理的数据
    List<String> tempList = log.split(RegExp('\n')); //先按照换行符分割数据
    RegExp tabReg = RegExp("\t");
    int maxLength = 0; //记录日志中最长行的宽度
    for (var s in tempList) {
      int sl = s.length;
      if (sl <= lineMax) {
        lineList.add(s);
        if (sl > maxLength) {
          maxLength = sl;
          Iterable<RegExpMatch> matchs = tabReg.allMatches(s);
          int tSize = matchs.length;
          maxLength += (tSize * 4); //Tab 长度4个字符
        }
        continue;
      }
      String tempS = s;
      while (true) {
        if (tempS.length <= lineMax ~/ 2) {
          lineList.add(tempS);
          tempS = '';
          break;
        }

        List tL = _computeSplitIndex(tempS, lineMax);
        String sp = tL[0];
        lineList.add(sp);
        if (sp.length == tempS.length) {
          break;
        }
        tempS = tempS.substring(sp.length);
        if (maxLength < tL[1]) {
          maxLength = tL[1];
          Iterable<RegExpMatch> matchs = tabReg.allMatches(sp);
          int tSize = matchs.length;
          maxLength += (tSize * 4);
        }
      }

      while (tempS.length > lineMax) {}
      if (tempS.isNotEmpty) {
        lineList.add(tempS);
      }
    }
    return lineList;
  }

  ///计算符合切割要求的位置(一个中文字符占2个位置，一个emoji等于一个中文字符宽度)
  ///[s] 待分割字符串；[max]每行最多好多个字符
  ///返回值[0] 为对应的字符串 [1]为字符串长度
  static List _computeSplitIndex(String s, int max) {
    Characters characters = s.characters;
    if (characters.length <= max ~/ 2) {
      return [s, _computeVirtualLength(s)];
    }

    String pre = characters.getRange(0, max ~/ 2 + 1).toString();
    int realLength = _computeVirtualLength(pre); //当前实时长度
    int index = max ~/ 2 + 1;
    while (realLength < max && index < characters.length) {
      int remainCount = max - realLength;
      if (remainCount >= 2) {
        int oldIndex = index;
        index += (remainCount ~/ 2 + 1);
        String nodeStr = characters.getRange(oldIndex, index + 1).toString();
        realLength += _computeVirtualLength(nodeStr);
      } else {
        if (remainCount == 1) {
          if (englishRegex.hasMatch(characters.elementAt(index + 1))) {
            index += 1;
            realLength += 1;
            break;
          } else {
            break;
          }
        } else {
          break;
        }
      }
    }

    if (index >= 0 && index < characters.length) {
      return [characters.getRange(0, index + 1).toString(), realLength];
    }
    return [s, _computeVirtualLength(s)];
  }

  ///计算字符串虚拟长度
  static int _computeVirtualLength(String s) {
    int englishCount = englishRegex.allMatches(s).length;
    return s.characters.length * 2 - englishCount;
  }
}

abstract class PrintFilter {
  bool filter(Level level, dynamic content, String? tag);
}

enum Level { V, D, I, W, E }

class LogConfig {
  static final LogColor _v = LogColor.rgb(187, 187, 187);
  static final LogColor _d = LogColor.rgb(37, 188, 36);
  static final LogColor _i = LogColor.rgb(255, 255, 0);
  static final LogColor _w = LogColor.rgb(255, 85, 85);
  static final LogColor _e = LogColor.rgb(187, 0, 0);

  LogColor _verbaseColor = _v;
  LogColor _debugColor = _d;
  LogColor _infoColor = _i;
  LogColor _warningColor = _w;
  LogColor _errorColor = _e;

  PrintFilter? _filter;

  int _stackOffset = 0;
  int _methodCount = 2;
  int _lineMaxLength = 120; //每行最多显示多少
  int _maxFileLength = 2 * 1024 * 1024 * 1024;

  bool _enablePrint;

  LogConfig(this._enablePrint);

  set verbaseColor(Color color) {
    _verbaseColor = LogColor.color(color);
  }

  set debugColor(Color color) {
    _debugColor = LogColor.color(color);
  }

  set infoColor(Color color) {
    _infoColor = LogColor.color(color);
  }

  set warningColor(Color color) {
    _warningColor = LogColor.color(color);
  }

  set errorColor(Color color) {
    _errorColor = LogColor.color(color);
  }

  LogColor getVerbaseColor() {
    return _verbaseColor;
  }

  LogColor getDebugColor() {
    return _debugColor;
  }

  LogColor getInfoColor() {
    return _infoColor;
  }

  LogColor getWarningColor() {
    return _warningColor;
  }

  LogColor getErrorColor() {
    return _errorColor;
  }

  set filter(filter) {
    _filter = filter;
  }

  PrintFilter? get filter => _filter;

  set stackOffset(int offset) {
    _stackOffset = offset;
  }

  int get staticOffset => _stackOffset;

  set methodCount(count) {
    _methodCount = count;
  }

  int get methodCount => _methodCount;

  set lineMaxLength(maxLen) {
    _lineMaxLength = maxLen;
  }

  int get lineMaxLength => _lineMaxLength;

  set maxFileLength(maxLen) {
    _maxFileLength = maxLen;
  }

  int get maxFileLength => _maxFileLength;

  set enablePrint(enableValue) {
    _enablePrint = enableValue;
  }

  bool get enablePrint => _enablePrint;
}

class LogColor {
  static const ansiEsc = '\x1B[38;2;';
  static const ansiDefault = '\x1B[0m';
  late final int r;
  late final int g;
  late final int b;

  LogColor.rgb(this.r, this.g, this.b);

  LogColor.color(Color color) {
    r = color.red;
    g = color.green;
    b = color.blue;
  }

  String? _pre;

  String getStrPre() {
    _pre ??= "$ansiEsc$r;$g;${b}m";
    return _pre!;
  }
}
