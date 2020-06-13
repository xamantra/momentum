import 'package:momentum/momentum.dart';

import '../persist-error3/index.dart';
import 'index.dart';

class PersistError4Model extends MomentumModel<PersistError4Controller> {
  PersistError4Model(
    PersistError4Controller controller, {
    this.data,
  }) : super(controller);

  final DummyObject3 data;

  @override
  void update({
    DummyObject3 data,
  }) {
    PersistError4Model(
      controller,
      data: data ?? this.data,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toJson() => {
    'data': data.toJson(),
  };

  @override
  PersistError4Model fromJson(Map<String, dynamic> json) {
    var map;
    return PersistError4Model(
      controller,
      data: map['data'],
    );
  }
}
