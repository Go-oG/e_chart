import 'package:e_chart/src/ext/int_ext.dart';
import 'package:flutter/material.dart';
import 'package:chart_xutil/chart_xutil.dart';

import '../../model/index.dart';
import '../rect_coord.dart';
import 'calendar_config.dart';

abstract class CalendarCoord extends RectCoord<CalendarConfig> {
  CalendarCoord(super.props);

  Rect dataToPoint(DateTime date);
}

///日历坐标系视图
class CalendarCoordImpl extends CalendarCoord {
  Map<String, CalendarNode> _nodeMap = {};
  double cellWidth = 0;
  double cellHeight = 0;
  int rowCount = 0;
  int columnCount = 0;

  CalendarCoordImpl(super.props);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    Pair<DateTime> pair = _adjustTime(props.range.start, props.range.end);
    int count = computeDayDiff(pair.start, pair.end);
    int tmpCount = count ~/ 7;
    if (count % 7 != 0) {
      tmpCount += 1;
    }
    if (props.direction == Direction.vertical) {
      columnCount = 7;
      rowCount = tmpCount;
    } else {
      columnCount = tmpCount;
      rowCount = 7;
    }
    _nodeMap = {};
    List<DateTime> timeList = buildDateRange(pair.start, pair.end, true);
    int rowIndex = 0;
    int columnIndex = 0;

    for (var time in timeList) {
      _nodeMap[key(time)] = CalendarNode(time, rowIndex, columnIndex);
      if (props.direction == Direction.vertical) {
        columnIndex += 1;
        if (columnIndex >= 7) {
          columnIndex = 0;
          rowIndex += 1;
        }
      } else {
        rowIndex += 1;
        if (rowIndex >= 7) {
          columnIndex += 1;
          rowIndex = 0;
        }
      }
    }
    num vw = width;
    num vh = height;
    if (props.cellSize.isNotEmpty) {
      if (props.cellSize.length == 1) {
        num? size = props.cellSize[0];
        if (size != null) {
          vw = columnCount * size;
          vh = rowCount * size;
        }
      } else if (props.cellSize.length == 2) {
        num? w = props.cellSize[0];
        if (w != null) {
          vw = columnCount * w;
        }
        num? h = props.cellSize[1];
        if (h != null) {
          vh = rowCount * h;
        }
      }
    }

    cellWidth = vw / columnCount;
    cellHeight = vh / rowCount;
    _nodeMap.forEach((key, node) {
      double left = node.column * cellWidth;
      double top = node.row * cellHeight;
      node.rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
    });

    ///移除范围以外的数据
    _nodeMap.removeWhere((key, value) {
      if (value.date.isAfterDay(props.range.end) || value.date.isBeforeDay(props.range.start)) {
        return true;
      }
      return false;
    });
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.clipRect(areaBounds);
    if (props.gridLineStyle != null) {
      var style = props.gridLineStyle!;
      for (int i = 0; i < columnCount; i++) {
        Offset o1 = Offset(i * cellWidth, 0);
        Offset o2 = Offset(i * cellWidth, rowCount * cellHeight);
        style.drawPolygon(canvas, mPaint, [o1, o2]);
      }
      for (int i = 0; i < rowCount; i++) {
        Offset o1 = Offset(0, i * cellHeight);
        Offset o2 = Offset(columnCount * cellWidth, i * cellHeight);
        style.drawPolygon(canvas, mPaint, [o1, o2]);
      }
    }
    if (props.borderStyle != null) {
      var style = props.borderStyle!;
      DateTime first = props.range.start;
      int year = first.year;
      int month = first.month;
      int diff = first.diffMonth(props.range.end);
      for (int i = 0; i <= diff; i++) {
        DateTime t1 = DateTime(year, month, 1);
        DateTime t2 = DateTime(year, month, t1.maxDay());
        if (t2.isAfter(props.range.end)) {
          t2 = props.range.end;
        }
        style.drawPolygon(canvas, mPaint, findDateRangePolygon(t1, t2));
      }
    }

    canvas.restore();
  }

  @override
  Rect dataToPoint(DateTime date) {
    date = date.first();
    CalendarNode? node = _nodeMap[key(date)];
    if (node == null) {
      throw ChartError('当前给定的日期不在范围内');
    }
    return node.rect;
  }

  ///给定在制定月份的边缘
  ///相关数据必须在给定的范围以内
  List<Offset> findMonthPolygon(int year, int month) {
    DateTime? startDate = findMinDate(year, month);
    DateTime? endDate = findMaxDate(year, month);
    if (endDate == null || startDate == null) {
      throw ChartError('在给定的年月中无法找到对应数据');
    }
    return findDateRangePolygon(startDate, endDate);
  }

  List<Offset> findDateRangePolygon(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      var t = end;
      end = start;
      start = t;
    }
    CalendarNode? startNode = _nodeMap[key(start)];
    CalendarNode? endNode = _nodeMap[key(end)];
    if (startNode == null || endNode == null) {
      throw ChartError('给定的时间必须在时间范围以内');
    }
    List<Offset> offsetList = [];
    if (props.direction == Direction.vertical) {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.column != columnCount - 1) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(cellWidth * (columnCount - startNode.column - 1), 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, endNode.rect.topRight.dy));
      offsetList.add(endNode.rect.topLeft);
      offsetList.add(endNode.rect.bottomLeft);
      if (endNode.column != 0) {
        Offset offset = endNode.rect.bottomLeft;
        offset = offset.translate(-cellWidth * endNode.column, 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, startNode.rect.bottomLeft.dy));
    } else {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.row != 0) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(0, cellHeight * startNode.row);
        offsetList.add(offset);
      }
      offsetList.add(Offset(endNode.rect.topRight.dx, offsetList.last.dy));
      offsetList.add(endNode.rect.bottomRight);
      if (endNode.row != rowCount - 1) {
        offsetList.add(endNode.rect.bottomLeft);
        offsetList.add(Offset(offsetList.last.dx, endNode.rect.bottom + (columnCount - endNode.column) * cellHeight));
      }
      offsetList.add(Offset(startNode.rect.bottomLeft.dx, offsetList.last.dy));
    }
    return offsetList;
  }

  DateTime? findMinDate(int year, int month) {
    DateTime? start;
    _nodeMap.forEach((key, value) {
      if (value.date.year == year && value.date.month == month) {
        if (start == null) {
          start = value.date;
        } else {
          if (value.date.isBeforeDay(start!)) {
            start = value.date;
          }
        }
      }
    });
    return start;
  }

  DateTime? findMaxDate(int year, int month) {
    DateTime? end;
    _nodeMap.forEach((key, value) {
      if (value.date.year == year && value.date.month == month) {
        if (end == null) {
          end = value.date;
        } else {
          if (value.date.isAfterDay(end!)) {
            end = value.date;
          }
        }
      }
    });
    return end;
  }

  ///将给定的数据调整到7的倍数，这样方便运算
  Pair<DateTime> _adjustTime(DateTime start, DateTime end) {
    final DateTime monthFirst = start.monthFirst();
    final DateTime monthEnd = end.monthLast();
    final int monthFirstWeek = monthFirst.weekday == 7 ? 0 : monthFirst.weekday;
    final int monthEndWeek = monthEnd.weekday == 7 ? 0 : monthEnd.weekday;

    DateTime startDateTime;
    DateTime endDateTime;
    if (props.sunFirst) {
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
    return Pair(startDateTime, endDateTime);
  }

  String key(DateTime time) {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    return '$year${month.padLeft(2, '0')}${day.padLeft(2, '0')}';
  }
}

class CalendarNode {
  final DateTime date;
  final int row;
  final int column;
  Rect rect = Rect.zero;

  CalendarNode(this.date, this.row, this.column);
}
