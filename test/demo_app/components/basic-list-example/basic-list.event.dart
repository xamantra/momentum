import 'package:momentum/momentum.dart';

enum BasicListEvent {
  reverseList,
  clearList,
  resetAll,
  resetAllClearHistory,
  restart,
}

class RestartEvent {
  final Momentum instance;

  RestartEvent(this.instance);
}
