import 'package:momentum/momentum.dart';

import 'counter-advance.controller.dart';

enum CounterAdvanceAction { Increment, Decrement }

class CounterAdvanceModel extends MomentumModel<CounterAdvanceController> {
  final int value;
  final CounterAdvanceAction action;

  CounterAdvanceModel(
    CounterAdvanceController controller, {
    this.value,
    this.action,
  }) : super(controller);

  @override
  void update({
    int value,
    CounterAdvanceAction action,
  }) {
    CounterAdvanceModel(
      controller,
      value: value ?? this.value,
      action: action ?? this.action,
    ).updateMomentum();
  }
}
