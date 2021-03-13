import 'package:momentum/momentum.dart';

import 'index.dart';

class DummyModel extends MomentumModel<DummyController> {
  DummyModel(
    DummyController controller, {
    this.value,
  }) : super(controller);

  final int? value;

  @override
  void update({
    int? value,
  }) {
    DummyModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }

  Map<String, dynamic> toJson() {
    return {
      'value': int.parse('dwdwd'), // purposely cause an error for testing.
    };
  }

  DummyModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return DummyModel(
      controller,
      value: int.parse('dwdwd'), // purposely cause an error for testing.
    );
  }
}
