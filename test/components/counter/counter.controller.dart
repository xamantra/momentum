import 'package:momentum/momentum.dart';

import 'index.dart';

class CounterController extends MomentumController<CounterModel> {
  @override
  CounterModel init() {
    return CounterModel(
      this,
      value: 0,
    );
  }

  void increment() {
    var newValue = model.value + 1;
    model.update(value: newValue);
  }

  void decrement() {
    var newValue = model.value - 1;
    model.update(value: newValue);
  }
}
