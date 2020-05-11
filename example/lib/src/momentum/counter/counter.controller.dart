import 'package:momentum/momentum.dart';

import 'counter.model.dart';

// The relationship between controllers and models is:
// 1 controller is to 1 Model (and vice versa).
// It means all your controllers must have a model attached to it (that is not attach to other controller). (and vice versa).
class CounterController extends MomentumController<CounterModel> {
  @override
  CounterModel init() {
    return CounterModel(
      this,
      value: 0,
    );
  }

  @override
  void bootstrap() async {
    await Future.delayed(Duration(milliseconds: 5000));
  }

  void increment() {
    // let's say model.value is currently = 1
    model.update(value: model.value + 1); // calling `model.update(...)` is like calling `setState` so it rebuilds all listeners.
    print('$this -> {value: ${model.value}'); // updated value. model.value is now = 2
  }
}
