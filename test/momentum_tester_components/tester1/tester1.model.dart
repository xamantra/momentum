import 'package:momentum/momentum.dart';

import 'index.dart';

class Tester1Model extends MomentumModel<Tester1Controller> {
  Tester1Model(
    Tester1Controller controller, {
    this.counter,
  }) : super(controller);

  final int counter;

  @override
  void update({
    int counter,
  }) {
    Tester1Model(
      controller,
      counter: counter ?? this.counter,
    ).updateMomentum();
  }
}
