import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/calendar/calendar_chart.dart';
import 'package:flutter/material.dart';
import 'item_style.dart';
import 'date_range.dart';
import 'font_style.dart';
import 'shape.dart';

/// 组件属性
/// 相关fontStyle 优先级如下
/// selectFontStyle > fontStyle > forbidStyle = subFontStyle
class CalenderSeries extends ChartSeries {
  late int year;
  late int month;
  late num shapeSize;
  CalendarShape? shape;
  Color? middleShapeColor;
  bool needDrawMarking;
  CalendarShape? markingShape;
  num markingSize;
  num markingTopMargin;
  Color? markingColor;
  num? markingRadius;
  num? headerHeight;
  num dividerHeight;
  Color? dividerColor;
  Color? lineColor;

  /// 周文字样式 */
  FontStyle? weekFontStyle;

  /// 选中的文字样式 */
  FontStyle? selectFontStyle;

  /// 选中日期的中间文字样式 */
  FontStyle? selectMiddleFontStyle;

  /// 一般数据的文字样式 */
  FontStyle fontStyle;

  /// 禁止选择数据的文字样式 */
  FontStyle? forbidFontStyle;

  /// 子文字的样式(上月下月文字) */
  FontStyle? subFontStyle;

  /// 一周的第一天是否为周日 默认false */
  bool sunFirst;

  /// 是否自动链接相邻点之间的日期 默认为true */
  bool autoLink;

  /// 当autoLink 为TRUE时，如果已选择了连续多日，
  /// 此时点击中间点是直接保留当前点击的日期的还是
  /// 以当前日期为起点或终点进行截取 默认为false
  bool resetWhenAutoLinkClick;

  /// 是否绘制中间点日期的Shape */
  bool drawMiddleShape;
  bool drawLastMonth;
  bool drawNextMonth;

  /// 默认选中的数据
  List<DateTime>? defaultDate;

  /// 最大可以选择的(该值受到defaultDate和chooseRange的影响)天数 */
  int? maxChooseCount;

  /// 可以选择的时间范围，如果为空则都可以选择 */
  DateRange? chooseRange;

  /// 作用同chooseRange一样 但是优先级高且更加灵活 */
  bool Function(int year, int month, int date)? onChooseFilter;

  /// 用于格式化日期显示
  /// 给定一个用年月日标识的日期返回其格式化的文字
  /// tips 月份是从1开始的
  String Function(int year, int month, int date)? dayFormat;

  String Function(int weekIndex)? weekFormat;

  FontStyle Function(int weekIndex)? weekStyleGenerator;

  CalendarItemStyle Function(int year, int month, int date, bool chosen, bool isToday, bool isLastMonth, bool isNextMonth)? styleGenerator;

  void Function(List<DateTime> values)? onChange;

  void Function(DateTime forbidDay)? onClickForbidDay;

  CalenderSeries(
    this.year,
    this.month,
    this.shapeSize, {
    this.shape,
    this.middleShapeColor,
    this.needDrawMarking = false,
    this.markingShape,
    this.markingSize = 2,
    this.markingTopMargin = 2,
    this.markingColor,
    this.markingRadius,
    this.headerHeight,
    this.dividerHeight = 0,
    this.dividerColor,
    this.lineColor,
    this.weekFontStyle,
    this.selectFontStyle,
    this.selectMiddleFontStyle,
    this.fontStyle = const FontStyle(14, Colors.black54),
    this.forbidFontStyle,
    this.subFontStyle,
    this.sunFirst = false,
    this.autoLink = true,
    this.resetWhenAutoLinkClick = false,
    this.drawMiddleShape = false,
    this.drawLastMonth = true,
    this.drawNextMonth = true,
    this.defaultDate,
    this.maxChooseCount,
    this.chooseRange,
    this.onChooseFilter,
    this.dayFormat,
    this.weekFormat,
    this.weekStyleGenerator,
    this.styleGenerator,
    this.onChange,
    this.onClickForbidDay,
    super.backgroundColor,
    super.id,
    super.animation,
    super.clip,
    super.z,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return CalendarView(this);
  }
}
