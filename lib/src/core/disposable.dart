
abstract class Disposable {
  bool _disposeFlag = false;

  bool get isDispose => _disposeFlag;

  void dispose() {
    _disposeFlag = true;
  }
}
