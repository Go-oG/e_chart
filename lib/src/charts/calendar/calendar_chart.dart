import 'package:flutter/material.dart';
import 'package:chart_xutil/chart_xutil.dart';

import '../../core/view.dart';
import 'calendar_series.dart';
import 'date_range.dart';
import 'item_style.dart';
import 'font_style.dart' as cf;
import 'shape.dart';


class CalendarView extends View {
  late final CalenderSeries _props;
  final List<DateTime> _oldSelectSet = [];
  final Set<String> _selectSet = {};
  final Map<String, _DateNode> _globalMap = {};

  bool _needComputeData = true;

  late Paint _mPaint;

  CalendarView(CalenderSeries props) {
    _props = props;
    _mPaint = Paint();
    _selectSet.addAll(_parsePropsDefaultDate(_props.defaultDate));
    //这里在开始就回调是为了解决第一次不回调的问题
    _notifyChangeListener();

    if (_props.defaultDate != null) {
      _oldSelectSet.clear();
      _oldSelectSet.addAll(_props.defaultDate!);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    if (_needComputeData || _globalMap.isEmpty) {
      _globalMap.clear();
      _globalMap.addAll(_fetchDateNode(_props.year, _props.month, width, height));
      _needComputeData = false;
    }
    _draw(canvas, width, height);
  }

  void _draw(Canvas canvas, num width, num height) {
    _mPaint.style = PaintingStyle.fill;
    _mPaint.color = _props.backgroundColor ?? Colors.white;
    canvas.drawRect(Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()), _mPaint);
    _drawWeek(canvas, width, height);
    _drawDate(canvas, width);
  }

  void _drawWeek(Canvas canvas, num w, num h) {
    var size = _computeContentSize(w, h, (_globalMap.length / 7).floor());
    var space = (w - size[0] * 7) / 7;
    var pointY = _adjustHeaderHeight() / 2;
    var weekTextStyle = _props.weekFontStyle ?? const cf.FontStyle(13, Color(0xFF999999));

    for (int i = 0; i < 7; i += 1) {
      var style = _getWeekStyle(i, _props.sunFirst);
      var text = _getWeekText(i, _props.sunFirst);

      TextSpan textSpan;
      if (style != null) {
        textSpan =
            TextSpan(text: text, style: TextStyle(color: style.color, fontSize: style.fontSize.toDouble(), fontWeight: style.fontWeight));
      } else {
        textSpan = TextSpan(
            text: text,
            style:
                TextStyle(color: weekTextStyle.color, fontSize: weekTextStyle.fontSize.toDouble(), fontWeight: weekTextStyle.fontWeight));
      }

      final TextPainter textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

      var left = i * (space + size[0]);
      var right = left + space + size[0];
      var centerX = (right + left) / 2.0;

      textPainter.layout(minWidth: 0, maxWidth: (right - left));
      final centerY = pointY - textPainter.height / 2;
      final offset = Offset(centerX - textPainter.width / 2.0, centerY);
      textPainter.paint(canvas, offset);
    }
  }

  // 绘制日期和分割线
  void _drawDate(Canvas canvas, num w) {
    var dividerHeight = _adjustDividerHeight();
    if (dividerHeight > 0) {
      _mPaint.color = _props.dividerColor ?? const Color(0xFFFCFCFC);
      canvas.drawRect(Rect.fromLTWH(0, _adjustHeaderHeight() + 1, w.toDouble(), dividerHeight.toDouble()), _mPaint);
    }

    List<List<_DateNode>> arrays = _splitData(_globalMap);
    for (var value in arrays) {
      if (value.length == 1) {
        var node = value[0];
        _drawNode(canvas, node, node.position, _NodeType.single, _isChosen(node, _selectSet));
      } else {
        for (int j = 0; j < value.length; j += 1) {
          var node = value[j];
          _NodeType type;
          if (j == 0) {
            type = _NodeType.start;
            var preDate = DateTime(node.year, node.month, node.day).subtract(const Duration(days: 1));

            if (_isDayChosen(preDate, _selectSet)) {
              type = _NodeType.middle;
            }
          } else if (j == value.length - 1) {
            type = _NodeType.end;
            var nextDate = DateTime(node.year, node.month, node.day).add(const Duration(days: 1));

            if (_isDayChosen(nextDate, _selectSet)) {
              type = _NodeType.middle;
            }
          } else {
            type = _NodeType.middle;
          }

          var chosen = _isChosen(node, _selectSet);
          if (!chosen) {
            type = _NodeType.single;
          }
          _drawNode(canvas, node, node.position, type, chosen);
        }
      }
    }
  }

  /// 绘制单一节点数据
  /// @param ctx
  /// @param node 数据
  /// @param position 包含了个体的绘制区域范围等信息,这里的信息全部应该换算成PX
  /// @param type -1 普通数据 0选中数据的起始点 1连续数据中间点 2连续数据结尾点
  /// @param chosen 表示是否选中
  void _drawNode(Canvas canvas, _DateNode node, _Position position, _NodeType type, bool chosen) {
    double top = node.position.top.toDouble();
    double left = node.position.left.toDouble();
    double width = node.position.width.toDouble();
    double height = node.position.height.toDouble();
    double shapeSize = node.position.shapeSize.toDouble();
    double verticalPadding = node.position.verticalPadding.toDouble();
    double levelPadding = node.position.levelPadding.toDouble();

    var itemStyle = _getItemStyle(node, type, chosen, shapeSize);
    if (itemStyle.drawNode! == false) {
      return;
    }

    var shapeRadius = node.position.shapeSize / 2.0;
    var centerX = left + levelPadding + (position.contentWidth) / 2.0;
    var centerY = top + verticalPadding + shapeRadius;

    // 绘制背景
    if (itemStyle.backgroundColor != null) {
      _mPaint.color = itemStyle.backgroundColor!;
      _mPaint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(left, top, width, height), _mPaint);
    }

    // 绘制连接线
    if (itemStyle.drawLine != null && itemStyle.drawLine!) {
      _mPaint.color = itemStyle.lineColor!;
      _mPaint.style = PaintingStyle.fill;
      var lineTop = centerY - shapeRadius;
      var tempWidth = (width - levelPadding - shapeRadius).floor();
      if (type == _NodeType.start) {
        canvas.drawRect(Rect.fromLTWH(centerX, lineTop, tempWidth.toDouble(), shapeSize), _mPaint);
      } else if (type == _NodeType.middle) {
        canvas.drawRect(Rect.fromLTWH(left - 0.5, lineTop, width, shapeSize), _mPaint);
      } else if (type == _NodeType.end) {
        canvas.drawRect(Rect.fromLTWH(left - 0.5, lineTop, tempWidth.toDouble(), shapeSize), _mPaint);
      } else {
        canvas.drawRect(Rect.fromLTWH(left, lineTop, width, shapeSize), _mPaint);
      }
    }

    // 绘制Shape
    if (itemStyle.drawShape != null && itemStyle.drawShape == true) {
      CalendarShape shape = itemStyle.shape!;
      _mPaint.color = shape.color;
      double radius = shape.cornerRadius.toDouble();
      if (shape.shape == ShapeStyle.circle) {
        radius = shapeRadius;
      }
      if (radius > shapeRadius) {
        radius = shapeRadius;
      }
      _drawRoundRect(canvas, centerX - shapeRadius, centerY - shapeRadius, shapeSize, shapeSize, radius, _mPaint);
    }

    // 绘制Marking
    if (itemStyle.drawMarking) {
      var markingTop = centerY + shapeRadius + position.markingTopMargin;
      CalendarShape markingShape = itemStyle.markingShape!;
      _mPaint.color = markingShape.color;

      var markingSize = position.markingSize.floor();
      double radius = markingShape.cornerRadius;

      if (radius > markingSize / 2) {
        radius = markingSize / 2;
      }
      if (markingShape.shape == ShapeStyle.circle) {
        radius = markingSize / 2.0;
      }
      _drawRoundRect(canvas, (1 + centerX - markingSize / 2), markingTop, markingSize, markingSize, radius, _mPaint);
    }

    // 绘制文字
    String dateStr;
    if (_props.dayFormat != null) {
      dateStr = _props.dayFormat!(node.year, node.month, node.day);
      if (dateStr.isEmpty) {
        dateStr = '${node.day}';
      }
    } else {
      dateStr = '${node.day}';
    }

    cf.FontStyle fs = itemStyle.labelStyle!;
    final textStyle = TextStyle(fontSize: fs.fontSize, fontWeight: fs.fontWeight, color: fs.color);
    final textSpan = TextSpan(text: dateStr, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout(minWidth: 0, maxWidth: width);
    final offset = Offset(centerX - textPainter.width / 2.0, centerY - textPainter.height / 2.0);
    textPainter.paint(canvas, offset);
  }

  /// 绘制圆角矩形
  /// @param cxt
  /// @param x 绘制中心 X坐标
  /// @param y 绘制中心 Y坐标
  /// @param width 矩形宽度
  /// @param height 矩形高度
  /// @param radius 圆角半径
  void _drawRoundRect(Canvas cxt, num x, num y, num width, num height, num radius, Paint paint) {
    cxt.drawRRect(
        RRect.fromLTRBR(x.toDouble(), y.toDouble(), (x + width).toDouble(), (y + height).toDouble(), Radius.circular(radius.toDouble())),
        paint);
  }

  /// 返回给定年月对应的日期数据(同时计算其位置属性)，包含其上一个月和下一个月的数据
  /// @param w canvas Width
  /// @param h canvas Height
  /// @param year 给定年
  /// @param month 给定月 从1 开始
  Map<String, _DateNode> _fetchDateNode(
    int year,
    int month,
    num w,
    num h,
  ) {
    List<_DateNode> list = [];
    DateTime today = DateTime.now();
    final DateTime monthFirst = DateTime(year, month, 1, 0, 0, 0);
    final int monthDayMax = monthFirst.maxDay();
    final DateTime monthEnd = DateTime(year, month, monthDayMax, 0, 0, 0);
    final int monthFirstWeek = monthFirst.weekday == 7 ? 0 : monthFirst.weekday;
    final int monthEndWeek = monthEnd.weekday == 7 ? 0 : monthEnd.weekday;

    DateTime startDateTime;
    DateTime endDateTime;
    if (_props.sunFirst) {
      if (monthFirstWeek == 0) {
        startDateTime = monthFirst;
      } else {
        startDateTime = monthFirst.subtract(Duration(days: monthFirstWeek));
      }
      if (monthEndWeek == 6) {
        endDateTime = monthEnd;
      } else {
        endDateTime = monthEnd.add(Duration(days: 6 - monthEndWeek));
      }
    } else {
      if (monthFirstWeek == 1) {
        startDateTime = monthFirst;
      } else {
        int week = monthFirstWeek == 0 ? 7 : monthFirstWeek;
        startDateTime = monthFirst.subtract(Duration(days: week - 1));
      }

      if (monthEndWeek == 0) {
        endDateTime = monthEnd;
      } else {
        int week = monthEndWeek == 0 ? 7 : monthEndWeek;
        endDateTime = monthEnd.add(Duration(days: 7 - week));
      }
    }

    int diffDay = _computeDayDiff(startDateTime, endDateTime);
    for (int i = 0; i <= diffDay; i += 1) {
      DateTime dateTmp = startDateTime.add(Duration(days: i));
      bool isToday = dateTmp.year == today.year && dateTmp.month == today.month && today.day == dateTmp.day;

      _DateNode node = _DateNode(
        dateTmp.year,
        dateTmp.month,
        dateTmp.day,
        dateTmp.weekday,
        isToday,
        dateTmp.isBefore(monthFirst),
        dateTmp.isAfter(monthEnd),
      );
      list.add(node);
    }

    List<num> contentSize = _computeContentSize(w, h, (list.length / 7).floor());
    var baseTop = _adjustDividerHeight() + _adjustHeaderHeight();
    Map<String, _DateNode> map = {};
    // 计算位置属性
    for (int i = 0; i < list.length; i += 1) {
      var node = list[i];
      node.position = _computePosition(node, i, baseTop, contentSize);
      map[node.key()] = node;
    }
    return map;
  }

  /// 分离数据，将其分割为连续和非连续数据,只有当autoLink 为TRUE时才有用
  List<List<_DateNode>> _splitData(Map<String, _DateNode> map) {
    List<_DateNode> data = List.from(map.values);
    data.sort((a, b) {
      return _sortFun(a, b);
    });
    List<List<_DateNode>> result = [];
    if (!_props.autoLink) {
      for (var value in data) {
        result.add([value]);
      }
      return result;
    }

    List<_DateNode> itemList = [];
    for (int i = 0; i < data.length; i += 1) {
      var first = data[i];
      if (!_isChosen(first, _selectSet)) {
        result.add([first]);
      } else if (itemList.isEmpty) {
        itemList.add(first);
      } else {
        var end = itemList[itemList.length - 1];
        var next = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
        if (next.year == first.year && next.month == first.month && next.day == first.day) {
          itemList.add(first);
        } else {
          itemList.sort(_sortFun);
          result.add(itemList);
          itemList = [first];
        }
      }
    }
    if (itemList.isNotEmpty) {
      result.add(itemList);
    }
    return result;
  }

  // 解析Props传进来的默认选中数据
  Set<String> _parsePropsDefaultDate(List<DateTime>? dataArray, {bool abandonAbnormalData = false}) {
    if (dataArray == null || dataArray.isEmpty) {
      return <String>{};
    }
    Set<String> set = <String>{};

    for (var value in dataArray) {
      if (abandonAbnormalData) {
        if (value.year == _props.year && value.month == _props.month) {
          set.add(getKey(value));
        }
      } else {
        set.add(getKey(value));
      }
    }
    return set;
  }

  // 修正选择的数据
  Set<String>? _correctSelectData(_DateNode node) {
    var nodeKey = node.key();
    var autoLink = _props.autoLink;
    List<String> newSelect = [];

    if (autoLink && _props.resetWhenAutoLinkClick && _selectSet.length >= 2) {
      newSelect.add(node.key());
      return Set.from(newSelect);
    }

    if (_isChosen(node, _selectSet)) {
      List<String> copyData = List.from(_selectSet);
      copyData.sort();

      newSelect = List.from(copyData.where((element) => (element != nodeKey)));

      if (!autoLink || newSelect.length <= 1) {
        return Set.from(newSelect);
      }

      var index = copyData.indexWhere((item) => item == nodeKey);

      if (index == 0 || index == copyData.length - 1) {
        // 头尾不处理
        return Set.from(newSelect);
      }

      var preCount = index;
      var nextCount = copyData.length - index - 1;
      if (preCount > nextCount) {
        newSelect = copyData.sublist(index + 1);
      } else {
        newSelect = copyData.sublist(index, nextCount + 1 + index);
      }
      return Set.from(newSelect);
    }

    // 添加新数据
    var maxChooseDay = _adjustMaxChooseDay();
    if (_selectSet.length >= maxChooseDay) {
      return null;
    }
    newSelect = List.from(_selectSet);
    newSelect.sort();

    if (!autoLink || newSelect.isEmpty) {
      newSelect.add(nodeKey);
      return Set.from(newSelect);
    }

    if (newSelect.length <= 1) {
      // 可能存在跨月导致这里为空
      _DateNode? tempFirst = _globalMap[newSelect[0]];
      tempFirst ??= _getDateNodeByKey(newSelect[0]);

      _DateNode firstDate;
      _DateNode endDate;
      if (node.isBefore(tempFirst)) {
        firstDate = node;
        endDate = tempFirst;
      } else {
        firstDate = tempFirst;
        endDate = node;
      }

      if (_computeDateNodeDiff(firstDate, endDate) + 1 > maxChooseDay) {
        return null;
      }
      newSelect = [];
      _fetchRangeDate(firstDate, endDate, true).forEach(
        (value) => newSelect.add(getKey(value)),
      );
      newSelect.sort();
      return Set.from(newSelect);
    }

    _DateNode? first = _globalMap[newSelect[0]];
    first ??= _getDateNodeByKey(newSelect[0]);

    _DateNode? end = _globalMap[newSelect[newSelect.length - 1]];
    end ??= _getDateNodeByKey(newSelect[newSelect.length - 1]);

    if (node.isBefore(first)) {
      if (_computeDateNodeDiff(node, end) + 1 > maxChooseDay) {
        return null;
      }
      newSelect = [];
      _fetchRangeDate(node, end, true).forEach(
        (value) => newSelect.add(getKey(value)),
      );
      newSelect.sort();
      return Set.from(newSelect);
    }

    if (node.isAfter(end)) {
      if (_computeDateNodeDiff(first, node) + 1 > maxChooseDay) {
        return null;
      }

      newSelect = [];
      _fetchRangeDate(first, node, true).forEach(
        (value) => newSelect.add(getKey(value)),
      );
      newSelect.sort();
      return Set.from(newSelect);
    }

    if (_computeDateNodeDiff(first, end) + 1 > maxChooseDay) {
      return null;
    }

    // 首尾之间
    newSelect.removeRange(0, newSelect.length);
    _fetchRangeDate(first, end, true).forEach(
      (value) => newSelect.add(getKey(value)),
    );
    return Set.from(newSelect);
  }

  num _adjustHeaderHeight() {
    if (_props.headerHeight != null && _props.headerHeight! > 0) {
      return _props.headerHeight!;
    }
    return _props.shapeSize;
  }

  num _adjustDividerHeight() {
    if (_props.dividerHeight > 0) {
      return _props.dividerHeight;
    }
    return 0;
  }

  num _adjustMarkingSize() {
    num size = 0;
    if (_props.needDrawMarking) {
      if (_props.markingSize > 0) {
        size = _props.markingSize;
      } else {
        size = 4;
      }
    }
    return size;
  }

  /// 修正用户给定的最大选择天数
  num _adjustMaxChooseDay() {
    if (_props.maxChooseCount != null && _props.maxChooseCount! > 0) {
      num max = _props.maxChooseCount!;
      if (_props.defaultDate != null && _props.defaultDate!.length > max) {
        max = _props.defaultDate!.length;
      }
      return max;
    }
    if (_props.chooseRange != null) {
      var start = _props.chooseRange!.startDate;
      var end = _props.chooseRange!.endDate;
      var diffDay = _computeDayDiff(start, end);
      if (_props.defaultDate != null && _props.defaultDate!.length > diffDay) {
        return _props.defaultDate!.length;
      }
      return diffDay;
    }
    return 100000000;
  }

  /// 计算给定数据对应的位置信息
  ///  [index] 改数据再原始数据里面的索引下标
  ///  [baseTop] 顶部区域占据的高度
  ///  [contentSize] 要绘制的数据点尺寸通过 computeContentSize 给出
  /// [contentSize]= [top,bottom,left,right,row,column,contentWidth,contentHeight,shapeSize,markingSize,markingTopMargin]
  _Position _computePosition(
    _DateNode node,
    num index,
    num baseTop,
    List<num> contentSize,
  ) {
    var hspace = contentSize[5];
    var vspace = contentSize[6];
    var row = (index / 7).floor();
    var column = (index % 7).floor();
    var top = baseTop + row * (contentSize[1] + vspace);
    var bottom = top + contentSize[1] + vspace;
    var left = column * (contentSize[0] + hspace);
    var right = left + contentSize[0] + hspace;
    var position = _Position();
    position.top = top;
    position.left = left;
    position.width = right - left;
    position.height = bottom - top;
    position.row = row;
    position.column = column;
    position.contentWidth = contentSize[0];
    position.contentHeight = contentSize[1];
    position.shapeSize = contentSize[2];
    position.markingSize = contentSize[3];
    position.markingTopMargin = contentSize[4];
    position.verticalPadding = vspace * 0.5;
    position.levelPadding = hspace * 0.5;
    return position;
  }

  /// 计算单个Item内容所占的宽度和高度
  /// 返回值[0]=width [1]=height,[2]=shapeSize,[3]=markingSize,[4]=markingTopMargin,[5]=hSpace,[6]=vSpace
  /// 所有返回值都进行了像素比例换算
  List<num> _computeContentSize(num w, num h, num row) {
    var maxWidth = w / 7;
    var remainHeight = h - _adjustHeaderHeight() - _adjustDividerHeight();
    var maxHeight = remainHeight / row;

    num markSize = _adjustMarkingSize();
    num shapeSize = _props.shapeSize;
    num width = _props.shapeSize;
    num height = _props.shapeSize + markSize;
    num marginTop = 0;
    if (_props.needDrawMarking) {
      if (_props.markingTopMargin > 0) {
        marginTop = _props.markingTopMargin;
      }
    }
    height += marginTop;

    if (width <= maxWidth && height <= maxHeight) {
      // 都满足则不进行任何计算
    } else if (width > maxWidth && height <= maxHeight) {
      var percent = maxWidth / width;
      height *= percent;
      width = maxWidth;
      shapeSize = width;
      markSize *= percent;
      marginTop *= percent;
    } else if (width <= maxWidth && height > maxHeight) {
      var percent = maxHeight / height;
      width *= percent;
      height = maxHeight;
      shapeSize = width;
      markSize *= percent;
      marginTop *= percent;
    } else {
      var wPercent = maxWidth / width;
      var hPercent = maxHeight / height;
      if (wPercent > hPercent) {
        // 高度比宽度超出更多
        height = maxHeight;
        width *= hPercent;
        return [width, height, width, markSize * hPercent, marginTop * hPercent];
      }
      width = maxWidth;
      height *= wPercent;
      shapeSize = width;
      markSize *= wPercent;
      marginTop *= wPercent;
    }

    var hSpace = (w - width * 7) / 7;
    var vSpace = (remainHeight - height * row) / row;

    return [width, height, shapeSize, markSize, marginTop, hSpace, vSpace];
  }

  // 获取单个节点的样式
  CalendarItemStyle _getItemStyle(_DateNode node, _NodeType type, bool chosen, num shapeSize) {
    CalendarItemStyle? style;
    if (_props.styleGenerator != null) {
      style = _props.styleGenerator!(node.year, node.month, node.day, chosen, node.isToday, node.isLastMonth, node.isNextMonth);
    }
    style ??= CalendarItemStyle();

    // 补全剩余参数
    var chooseStyle = _props.selectFontStyle ?? const cf.FontStyle(14, Colors.white, fontWeight: FontWeight.normal);
    var textStyle = _props.fontStyle;
    var subTextStyle = _props.subFontStyle ?? const cf.FontStyle(14, Color(0xFF8a8a8a), fontWeight: FontWeight.normal);
    var forbidStyle = _props.forbidFontStyle ?? const cf.FontStyle(14, Color(0xFF8a8a8a), fontWeight: FontWeight.normal);

    if (style.drawNode == null) {
      if (node.isLastMonth) {
        style.drawNode = _props.drawLastMonth;
      } else if (node.isNextMonth) {
        style.drawNode = _props.drawLastMonth;
      } else {
        style.drawNode = true;
      }
    }

    if (style.labelStyle == null) {
      if (chosen) {
        if (type == _NodeType.middle && _props.selectMiddleFontStyle != null) {
          style.labelStyle = _props.selectMiddleFontStyle;
        } else {
          style.labelStyle = chooseStyle;
        }
      } else if (!_allowChoose(node)) {
        style.labelStyle = forbidStyle;
      } else if (node.isLastMonth || node.isNextMonth) {
        style.labelStyle = subTextStyle;
      } else {
        style.labelStyle = textStyle;
      }
    }

    if (style.drawShape == null) {
      if (chosen) {
        if (type == _NodeType.middle) {
          style.drawShape = _props.drawMiddleShape;
        } else {
          style.drawShape = true;
        }
      } else {
        style.drawShape = false;
      }
    }

    style.shape ??= _props.shape ?? const CalendarShape(ShapeStyle.circle, Color(0xFF0091FF), true, 0);

    style.markingShape ??= _props.markingShape ?? const CalendarShape(ShapeStyle.circle, Color(0xFF0091FF), true, 0);

    style.markingShapeSize ??= _props.markingSize > 0 ? _props.shapeSize : 2;

    style.drawLine ??= chosen && type != _NodeType.single;

    if (style.lineColor == null) {
      if (_props.lineColor != null) {
        style.lineColor = _props.lineColor;
      } else {
        style.lineColor = style.shape!.color.withOpacity(0.5);
      }
    }
    return style;
  }

  String _getWeekText(int index, bool sunFirst) {
    if (_props.weekFormat != null) {
      int weekIndex;
      if (sunFirst) {
        weekIndex = [7, 1, 2, 3, 4, 5, 6][index];
      } else {
        weekIndex = [1, 2, 3, 4, 5, 6, 7][index];
      }

      var weekStr = _props.weekFormat!(weekIndex);
      if (weekStr.isNotEmpty) {
        return weekStr;
      }
    }
    if (sunFirst) {
      return ['日', '一', '二', '三', '四', '五', '六'][index];
    }
    return ['一', '二', '三', '四', '五', '六', '日'][index];
  }

  cf.FontStyle? _getWeekStyle(int index, bool sunFirst) {
    if (_props.weekStyleGenerator != null) {
      int weekIndex;
      if (sunFirst) {
        weekIndex = [7, 1, 2, 3, 4, 5, 6][index];
      } else {
        weekIndex = [1, 2, 3, 4, 5, 6, 7][index];
      }

      return _props.weekStyleGenerator!.call(weekIndex);
    }
    return null;
  }

  // 判断是否允许选择
  bool _allowChoose(_DateNode node) {
    if (_props.onChooseFilter != null) {
      return _props.onChooseFilter!(node.year, node.month, node.day);
    }

    if (_props.chooseRange != null) {
      var range = _props.chooseRange!;
      var start = range.startDate;
      var end = range.endDate;
      var cur = DateTime(node.year, node.month, node.day);
      return (cur.isSameDay(start) || cur.isAfterDay(start)) && (cur.isBeforeDay(end) || cur.isSameDay(end));
    }
    return true;
  }

  void changeMaxChooseCount(int? maxCount) {
    _props.maxChooseCount = maxCount;
    if (_props.maxChooseCount != null && _props.maxChooseCount! >= 1 && _selectSet.length > _props.maxChooseCount!) {
      _changeSelectData(_parsePropsDefaultDate(_props.defaultDate));
    }
    invalidate();
  }

  void changeChooseRange(DateRange? range) {
    if (_props.chooseRange == null && range == null) {
      return;
    }
    if (range == _props.chooseRange) {
      return;
    }

    if (_props.chooseRange != null) {
      DateRange oldRange = _props.chooseRange!;
      bool hasChange = false;
      var startKey = getKey(oldRange.startDate);
      var endKey = getKey(oldRange.endDate);
      List<String> list = List.from(_selectSet);
      for (int i = 0; i < list.length; i += 1) {
        var nodeKey = _getDateNodeByKey(list[i]).key();
        if (nodeKey.compareTo(startKey) <= -1 || nodeKey.compareTo(endKey) >= 1) {
          hasChange = true;
          break;
        }
      }
      if (hasChange) {
        _changeSelectData(_parsePropsDefaultDate(_props.defaultDate));
        invalidate();
      }
    } else {
      _changeSelectData(_parsePropsDefaultDate(_props.defaultDate));
      invalidate();
    }
  }

  void changeAutoLink(bool autoLink) {
    if (_selectSet.length > 1) {
      List<String> list = List.from(_selectSet);
      list.sort();
      bool hasChange = false;
      for (int i = 1; i < list.length; i += 1) {
        var start = _getDateNodeByKey(list[i - 1]);
        var end = _getDateNodeByKey(list[i]);
        var diff = _computeDateNodeDiff(start, end);
        if (diff != 1) {
          hasChange = true;
          break;
        }
      }
      if (hasChange) {
        _changeSelectData(_parsePropsDefaultDate(_props.defaultDate));
        invalidate();
      }
    }
  }

  void changeDefaultData(List<DateTime>? list) {
    var oldSize = _oldSelectSet.length;
    var newSize = list?.length ?? 0;
    if (oldSize != newSize) {
      _changeSelectData(_parsePropsDefaultDate(list));
      _props.defaultDate = list;
      invalidate();
    } else if (newSize > 0) {
      var oldKeySet = <String>{};
      for (var value in _oldSelectSet) {
        oldKeySet.add(getKey(value));
      }
      bool hasChange = false;
      for (int i = 0; i < newSize; i += 1) {
        var key = getKey(list![i]);
        if (!oldKeySet.contains(key)) {
          hasChange = true;
          break;
        }
      }
      if (hasChange) {
        _oldSelectSet.clear();
        if (list != null) {
          _oldSelectSet.addAll(list);
        }
        _props.defaultDate = list;
        _changeSelectData(_parsePropsDefaultDate(_props.defaultDate));
        invalidate();
      }
    }
  }

  void changeYearMonth(int year, int month) {
    if (_props.year == year && _props.month == month) {
      return;
    }
    _props.year = year;
    _props.month = month;
    _markReCreateData();
    invalidate();
  }

  void changeShapeSize(num shapeSize) {
    if (_props.shapeSize == shapeSize) {
      return;
    }
    _props.shapeSize = shapeSize;
    _markReCreateData();
    invalidate();
  }

  void changeDividerHeight(num dividerHeight) {
    if (_props.dividerHeight == dividerHeight) {
      return;
    }
    _props.dividerHeight = dividerHeight;
    _markReCreateData();
    invalidate();
  }

  void changeHeaderHeight(num headerHeight) {
    if (_props.headerHeight == headerHeight) {
      return;
    }
    _props.headerHeight = headerHeight;
    _markReCreateData();
    invalidate();
  }

  void changeMarkingSize(double markingSize) {
    if (_props.markingSize == markingSize) {
      return;
    }
    _props.markingSize = markingSize;
    _markReCreateData();
    invalidate();
  }

  void changeMarkingTopMargin(double margin) {
    if (_props.markingTopMargin == margin) {
      return;
    }
    _props.markingTopMargin = margin;
    _markReCreateData();
    invalidate();
  }

  void changeSunFirst(bool sunFirst) {
    if (_props.sunFirst == sunFirst) {
      return;
    }
    _props.sunFirst = sunFirst;
    _markReCreateData();
    invalidate();
  }

  void changeNeedDrawMarking(bool needDrawMarking) {
    if (_props.needDrawMarking == needDrawMarking) {
      return;
    }
    _props.needDrawMarking = needDrawMarking;
    _markReCreateData();
    invalidate();
  }

  void _markReCreateData() {
    _needComputeData = true;
  }

  void _changeSelectData(Iterable<String>? set) {
    _selectSet.clear();
    if (set != null) {
      _selectSet.addAll(set);
    }
    _notifyChangeListener();
  }

  void _notifyChangeListener() {
    if (_props.onChange != null) {
      List<_DateNode> tempArray = [];
      for (var value in _selectSet) {
        tempArray.add(_getDateNodeByKey(value));
      }
      tempArray.sort(_sortFun);
      List<DateTime> result = List.from(tempArray.map((e) => DateTime(e.year, e.month, e.day)));
      _props.onChange!.call(result);
    }
  }

  // 点击事件命中测试
  void clickHitTest(num x, num y) {
    var baseTop = _adjustDividerHeight() + _adjustHeaderHeight();
    if (y <= baseTop) {
      return;
    }
    List<_DateNode> array = List.from(_globalMap.values);
    for (int i = 0; i < array.length; i += 1) {
      var node = array[i];
      var position = node.position;
      var top = position.top;
      var bottom = position.top + position.height;
      var left = position.left;
      var right = position.left + position.width;
      var clickHit = x >= left && x <= right && y >= top && y <= bottom;
      var canChoose = _allowChoose(node);
      if (clickHit && !canChoose) {
        if (_props.onClickForbidDay != null) {
          _props.onClickForbidDay!(DateTime(node.year, node.month, node.day));
        }
        break;
      }
      if (clickHit && canChoose) {
        var newData = _correctSelectData(node);
        if (newData != null) {
          _changeSelectData(newData);
          invalidate();
        }
        break;
      }
    }
  }
}

class _Position {
  late num left;

  late num top;

  late num width;

  late num height;

  late num contentWidth;

  late num contentHeight;

  late num verticalPadding;

  late num levelPadding;

  late num shapeSize;

  late num markingSize;

  late num markingTopMargin;

  late num row;

  late num column;
}

class _DateNode {
  final int year;

  final int month;

  final int day;

  final int week;

  final bool isToday;

  final bool isLastMonth;

  final bool isNextMonth;

  late _Position position;

  _DateNode(this.year, this.month, this.day, this.week, this.isToday, this.isLastMonth, this.isNextMonth);

  String key() {
    String monthStr = month < 10 ? '0$month' : '$month';
    String dateStr = day < 10 ? '0$day' : '$day';
    return '$year$monthStr$dateStr';
  }

  @override
  String toString() {
    String monthStr = month < 10 ? '0$month' : '$month';
    String dateStr = day < 10 ? '0$day' : '$day';
    return '$year-$monthStr-$dateStr';
  }

  bool isBefore(_DateNode second) {
    return DateTime(year, month, day).isBefore(DateTime(second.year, second.month, second.day));
  }

  bool isAfter(_DateNode second) {
    return DateTime(year, month, day).isAfter(DateTime(second.year, second.month, second.day));
  }
}

enum _NodeType {
  single,
  start,
  middle,
  end,
}

// 计算两个日期之间相差的天数
int _computeDayDiff(DateTime start, DateTime end) {
  return end.difference(start).inDays;
}

int _computeDateNodeDiff(_DateNode start, _DateNode end) {
  DateTime startDay = DateTime(start.year, start.month, start.day);
  DateTime endDay = DateTime(end.year, end.month, end.day);
  return _computeDayDiff(startDay, endDay);
}

String getKey(DateTime day) {
  int year = day.year;
  int month = day.month;
  int date = day.day;
  String monthStr = month < 10 ? '0$month' : '$month';
  String dateStr = date < 10 ? '0$date' : '$date';
  return '$year$monthStr$dateStr';
}

// 根据Key生成DateNode 注意这里并没有对位置信息进行计算
_DateNode _getDateNodeByKey(String key) {
  int year = int.parse(key.substring(0, 4), radix: 10);
  int month = int.parse(key.substring(4, 6), radix: 10);
  int day = int.parse(key.substring(6, 8), radix: 10);

  DateTime today = DateTime.now();
  DateTime dayObj = DateTime(year, month, day);
  int week = dayObj.weekday;
  bool isToday = year == today.year && today.month == month && today.day == day;
  return _DateNode(year, month, day, week, isToday, false, false);
}

bool _isChosen(_DateNode node, Set<String>? selectSet) {
  if (selectSet == null || selectSet.isEmpty) {
    return false;
  }
  return selectSet.contains(node.key());
}

bool _isDayChosen(DateTime date, Set<String>? selectSet) {
  if (selectSet == null || selectSet.isEmpty) {
    return false;
  }
  return selectSet.contains(getKey(date));
}

int _sortFun(_DateNode a, _DateNode b) {
  if (a.isBefore(b)) {
    return -1;
  }
  if (a.isAfter(b)) {
    return 1;
  }
  return 0;
}

// 根据两个日期点 返回两个日期点之间的日期
List<DateTime> _fetchRangeDate(
    _DateNode start,
    _DateNode end,
    bool include,
    ) {
  DateTime firstDate = DateTime(start.year, start.month, start.day, 0, 0, 0);

  int dayDiff = _computeDateNodeDiff(start, end);
  List<DateTime> array = [];
  if (include) {
    array.add(firstDate);
  }
  for (int i = 1; i < dayDiff; i += 1) {
    DateTime tempDate = firstDate.add(Duration(days: i));
    array.add(tempDate);
  }
  if (include) {
    array.add(DateTime(end.year, end.month, end.day, 0, 0, 0));
  }
  return array;
}