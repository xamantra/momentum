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

  @override
  Future<bool> skipPersist() async => true;

  void increment() {
    var newValue = model.value + 1;
    model.update(value: newValue);
  }

  void decrement() {
    var newValue = model.value - 1;
    model.update(value: newValue);
  }
}
