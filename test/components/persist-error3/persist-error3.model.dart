import 'package:momentum/momentum.dart';

import 'index.dart';

class PersistError3Model extends MomentumModel<PersistError3Controller> {
  PersistError3Model(
    PersistError3Controller controller, {
    this.data,
  }) : super(controller);

  final DummyObject3 data;

  @override
  void update({
    DummyObject3 data,
  }) {
    PersistError3Model(
      controller,
      data: data ?? this.data,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toMap() => null;

  @override
  PersistError3Model fromMap(Map<String, dynamic> json) {
    var map;
    return PersistError3Model(
      controller,
      data: map['data'],
    );
  }
}

class DummyObject3 {
  final int value;

  DummyObject3(this.value);

  Map<String, dynamic> toMap() {
    return {
      'value': value,
    };
  }

  static DummyObject3 fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return DummyObject3(
      map['value'],
    );
  }
}
