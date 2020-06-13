import 'package:momentum/momentum.dart';

import 'index.dart';

class PersistErrorModel extends MomentumModel<PersistErrorController> {
  PersistErrorModel(
    PersistErrorController controller, {
    this.data,
  }) : super(controller);

  final DummyObject data;

  @override
  void update({
    DummyObject data,
  }) {
    PersistErrorModel(
      controller,
      data: data ?? this.data,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}

class DummyObject {
  final int value;

  DummyObject(
    this.value,
  );
}
