import 'package:momentum/momentum.dart';

import 'index.dart';

class Tester1Controller extends MomentumController<Tester1Model> {
  @override
  Tester1Model init() {
    return Tester1Model(
      this,
      counter: 0,
    );
  }

  void increment() {
    model.update(counter: model.counter + 1);
  }

  void decrement() {
    model.update(counter: model.counter - 1);
  }
}
