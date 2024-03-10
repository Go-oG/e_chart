import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

abstract class ChartView extends RenderNode {
  Context? _context;

  Context get context => _context!;

  ///=========生命周期回调方法开始==================
  ///所有的生命周期函数都是由Context进行调用

  ///该回调只会发生在视图创建后，且只会回调一次
  ///绝大部分子类都不应该覆写该方法
  void attach(Context context, RenderNode parent) {
    resetLayoutInfo();
    forceLayout = true;
    _context = context;
    this.parent = parent;
    onCreate();
  }

  ///创建后的回调，在该方法后可以安全的使用Context
  void onCreate() {}

  ///视图进入已开始状态
  void onStart() {}

  ///视图进入停止状态
  void onStop() {}

  ///由Context负责回调
  ///当该方法被调用时标志着当前View即将被销毁
  ///你可以在这里进行资源释放等操作
  @override
  void dispose() {
    super.dispose();
    onDispose();
    clearCommand();
    _defaultCommandCallback = null;
    unBindSeries();
    _context = null;
  }

  void onDispose() {}

  ///=============处理Series和其绑定时相关的操作=============
  ChartSeries? _series;

  ///存储命令执行相关的操作
  Map<Command, VoidFun1<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap = {};
  }

  void registerCommand(Command c, VoidFun1<Command> callback, [bool allowReplace = true]) {
    var old = _commandMap[c];
    if (!allowReplace && callback != old) {
      throw ChartError('not allow replace');
    }
    _commandMap[c] = callback;
  }

  void removeCommand(int code) {
    _commandMap.remove(code);
  }

  ///绑定Series 主要是将Series相关的命令传递到当前View
  VoidCallback? _defaultCommandCallback;

  void bindSeries(covariant ChartSeries series) {
    unBindSeries();
    _series = series;
    _defaultCommandCallback = () {
      onReceiveCommand(_series?.value);
    };
    series.addListener(_defaultCommandCallback!);
    registerCommandHandler();
  }

  void unBindSeries() {
    _commandMap.clear();
    if (_defaultCommandCallback != null) {
      _series?.removeListener(_defaultCommandCallback!);
    }
    _series = null;
  }

  void registerCommandHandler() {
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onSeriesConfigChangeCommand;
  }

  void unregisterCommandHandler() {
    _commandMap.remove(Command.updateData);
    _commandMap.remove(Command.invalidate);
    _commandMap.remove(Command.reLayout);
    _commandMap.remove(Command.configChange);
  }

  void onReceiveCommand(covariant Command? c) {
    if (c == null) {
      return;
    }

    var op = _commandMap[c];
    if (op == null) {
      Logger.w('$c 无法找到能出来该命令相关的回调');
      return;
    }
    // try {
    op.call(c);
    // } catch (e) {
    //   Logger.e(e);
    // }
  }

  void onInvalidateCommand(covariant Command c) {
    requestDraw();
  }

  void onRelayoutCommand(covariant Command c) {
    requestLayout();
  }

  void onSeriesConfigChangeCommand(covariant Command c) {
    ///自身配置改变我们只更新当前的配置和节点布局
    onStop();
    onStart();
    requestLayoutSelf();
  }

  void onUpdateDataCommand(covariant Command c) {
    requestDraw();
  }

  ///分配索引
  ///返回值表示消耗了好多的索引
  int allocateDataIndex(int index) {
    return 0;
  }

  ///是否忽略索引分配
  bool ignoreAllocateDataIndex() {
    return false;
  }

  @override
  void resetLayoutInfo() {
    super.resetLayoutInfo();
    forceLayout = true;
  }

}
