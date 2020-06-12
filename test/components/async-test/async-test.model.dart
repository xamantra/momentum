import 'package:momentum/momentum.dart';

import 'index.dart';

class AsyncTestModel extends MomentumModel<AsyncTestController> {
  AsyncTestModel(
    AsyncTestController controller, {
    this.value,
    this.name,
  }) : super(controller);

  final int value;
  final String name;

  @override
  void update({
    int value,
    String name,
  }) {
    AsyncTestModel(
      controller,
      value: value ?? this.value,
      name: name ?? this.name,
    ).updateMomentum();
  }
}
