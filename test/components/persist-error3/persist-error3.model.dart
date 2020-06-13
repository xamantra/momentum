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
  Map<String, dynamic> toJson() => null;

  @override
  PersistError3Model fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  static DummyObject3 fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return DummyObject3(
      map['value'],
    );
  }
}
