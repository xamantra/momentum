import 'package:momentum/momentum.dart';

import 'counter.controller.dart';

// The relationship between models and controllers is:
// 1 Model is to 1 Controller (and vice versa).
// It means all your models must have a controller attached to it (that is not attach to other model). (and vice versa).
class CounterModel extends MomentumModel<CounterController> {
  final int value;

  CounterModel(
    CounterController controller, {
    this.value,
  }) : super(controller);

  @override
  void update({
    int value,
  }) {
    CounterModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}
