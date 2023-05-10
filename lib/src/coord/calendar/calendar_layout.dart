import 'package:flutter/material.dart';
import 'package:chart_xutil/chart_xutil.dart';

import '../../model/enums/direction.dart';
import '../../model/range.dart';
import '../rect_coord_layout.dart';
import 'calendar.dart';

class CalendarLayout extends RectCoordLayout<Calendar> {
  final Map<DateTime, CalendarNode> _nodeMap = {};

  double _cellWidth = 0;
  double _cellHeight = 0;
  int _rowCount = 0;
  int _columnCount = 0;

  CalendarLayout(super.props);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    Pair<DateTime> pair = _adjustTime(props.range.start, props.range.end);
    int count = computeDayDiff(pair.start, pair.end);
    int tmpCount = count ~/ 7;
    if (count % 7 != 0) {
      tmpCount += 1;
    }

    int rowCount;
    int columnCount;
    if (props.direction == Direction.vertical) {
      columnCount = 7;
      rowCount = tmpCount;
    } else {
      columnCount = tmpCount;
      rowCount = 7;
    }

    _nodeMap.clear();
    List<DateTime> timeList = buildDateRange(pair.start, pair.end, true);
    int rowIndex = 0;
    int columnIndex = 0;

    for (var element in timeList) {
      _nodeMap[element] = CalendarNode(element, rowIndex, columnIndex);
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

    double cellWidth = vw / columnCount;
    double cellHeight = vh / rowCount;
    _nodeMap.forEach((key, node) {
      double left = node.column * cellWidth;
      double top = node.row * cellHeight;
      node.rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
    });

    ///移除范围以外的数据
    _nodeMap.removeWhere((key, value) {
      if (key.isAfterDay(props.range.end) || key.isBeforeDay(props.range.start)) {
        return true;
      }
      return false;
    });

    _cellWidth = cellWidth;
    _cellHeight = _cellHeight;
    _rowCount = rowCount;
    _columnCount = columnCount;
  }

  @override
  Rect dataToPoint(DateTime date, bool b) {
    date = date.first();
    CalendarNode? node = _nodeMap[date];
    if (node == null) {
      throw FlutterError('当前给定的日期不在范围内');
    }
    return node.rect;
  }

  ///给定在制定月份的边缘
  ///相关数据必须在给定的范围以内
  List<Offset> findMonthPolygon(int year, int month) {
    DateTime? startDate = findMinDate(year, month);
    DateTime? endDate = findMaxDate(year, month);
    if (endDate == null || startDate == null) {
      throw FlutterError('在给定的年月中无法找到对应数据');
    }

    CalendarNode startNode = _nodeMap[startDate]!;
    CalendarNode endNode = _nodeMap[endDate]!;

    List<Offset> offsetList = [];
    if (props.direction == Direction.vertical) {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.column != _columnCount - 1) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(_cellWidth * (_columnCount - startNode.column - 1), 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, endNode.rect.topRight.dy));
      offsetList.add(endNode.rect.topLeft);
      offsetList.add(endNode.rect.bottomLeft);
      if (endNode.column != 0) {
        Offset offset = endNode.rect.bottomLeft;
        offset = offset.translate(-_cellWidth * endNode.column, 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, startNode.rect.bottomLeft.dy));
    } else {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.row != 0) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(0, _cellHeight * startNode.row);
        offsetList.add(offset);
      }
      offsetList.add(Offset(endNode.rect.topRight.dx, offsetList.last.dy));
      offsetList.add(endNode.rect.bottomRight);
      if (endNode.row != _rowCount - 1) {
        offsetList.add(endNode.rect.bottomLeft);
        offsetList.add(Offset(offsetList.last.dx, endNode.rect.bottom + (_columnCount - endNode.column) * _cellHeight));
      }
      offsetList.add(Offset(startNode.rect.bottomLeft.dx, offsetList.last.dy));
    }
    return offsetList;
  }

  DateTime? findMinDate(int year, int month) {
    DateTime? start;
    _nodeMap.forEach((key, value) {
      if (key.year == year && key.month == month) {
        if (start == null) {
          start = key;
        } else {
          if (key.isBeforeDay(start!)) {
            start = key;
          }
        }
      }
    });

    return start;
  }

  DateTime? findMaxDate(int year, int month) {
    DateTime? end;
    _nodeMap.forEach((key, value) {
      if (key.year == year && key.month == month) {
        if (end == null) {
          end = key;
        } else {
          if (key.isAfterDay(end!)) {
            end = key;
          }
        }
      }
    });

    return end;
  }

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
}

class CalendarNode {
  final DateTime date;
  final int row;
  final int column;
  Rect rect = Rect.zero;

  CalendarNode(this.date, this.row, this.column);
}
