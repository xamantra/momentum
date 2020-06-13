import 'package:momentum/momentum.dart';

import 'index.dart';

class SyncTestModel extends MomentumModel<SyncTestController> {
  SyncTestModel(
    SyncTestController controller, {
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
    SyncTestModel(
      controller,
      value: value ?? this.value,
      name: name ?? this.name,
    ).updateMomentum();
  }
}
