import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

class HeatMapLayout extends ChartLayout<HeatMapSeries,List<HeatMapData>> {
  List<HeatMapNode> _nodeList = [];

  List<HeatMapNode> get nodeList => _nodeList;

  @override
  void onLayout(List<HeatMapData> data, LayoutAnimatorType type) {
    List<HeatMapNode> oldList=_nodeList;
    List<HeatMapNode> newList=convertData(data);
    layoutNode(newList);
    DiffResult<HeatMapNode,HeatMapData> result=DiffUtil.diff(oldList, newList, (p0) => p0.data, (p0, p1, newData){
      HeatMapNode node=HeatMapNode(p0);
      node.rect=Rect.fromCenter(center: p1.rect.center, width: 0, height: 0);
      return node;
    });

    Map<HeatMapData,Rect> startMap=result.startMap.map((key, value) => MapEntry(key, value.rect));
    Map<HeatMapData,Rect> endMap=result.endMap.map((key, value) => MapEntry(key, value.rect));

    ChartRectTween rectTween = ChartRectTween(Rect.zero, Rect.zero);
    ChartDoubleTween doubleTween = ChartDoubleTween(props: series.animatorProps);
    doubleTween.startListener = () {
      _nodeList = result.curList;
    };
    doubleTween.endListener=(){
      _nodeList=result.finalList;
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      var v = doubleTween.value;
      each(result.curList, (p0, p1) {
        rectTween.changeValue(startMap[p0.data]!, endMap[p0.data]!);
        Rect rect = rectTween.safeGetValue(v);
        p0.rect = rect;
      });
      notifyLayoutUpdate();
    });
    doubleTween.start(context,type==LayoutAnimatorType.update);
  }

  List<HeatMapNode> convertData(List<HeatMapData> dataList){
    return List.from(dataList.map((e) => HeatMapNode(e)));
  }

  void layoutNode(List<HeatMapNode> nodeList) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordSystem == CoordSystem.grid) {
      gridLayout = context.findGridCoord();
    } else {
      calendarLayout = context.findCalendarCoord(series.xAxisIndex);
    }
    for(var node in nodeList){
      var data=node.data;
      Rect? rect;
      if (gridLayout != null) {
        rect = gridLayout.dataToPoint(series.xAxisIndex, data.x, series.yAxisIndex, data.y);
      } else if (calendarLayout != null) {
        rect = calendarLayout.dataToPosition(data.x.data);
      }
      if (rect == null) {
        throw ChartError('无法布局 $gridLayout  $calendarLayout');
      }
      node.rect = rect;
    }
  }


}
