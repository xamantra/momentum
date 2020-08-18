import 'package:momentum/momentum.dart';

import 'index.dart';

class DummyModel extends MomentumModel<DummyController> {
  DummyModel(
    DummyController controller, {
    this.value,
  }) : super(controller);

  final String value;

  @override
  void update({
    String value,
  }) {
    DummyModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}

class DummyPersistedModel extends MomentumModel<DummyPersistedController> {
  DummyPersistedModel(
    DummyPersistedController controller, {
    this.counter,
  }) : super(controller);

  final int counter;

  @override
  void update({
    int counter,
  }) {
    DummyPersistedModel(
      controller,
      counter: counter ?? this.counter,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'counter': counter,
    };
  }

  @override
  DummyPersistedModel fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return DummyPersistedModel(
      controller,
      counter: json['counter'],
    );
  }
}
