import '../model/view_state.dart';

abstract class ViewStateResolver<T> {
  T? resolve(Set<ViewState>? states);
}