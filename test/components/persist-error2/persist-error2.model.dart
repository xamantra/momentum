import 'dart:convert';

import 'package:momentum/momentum.dart';

import '../../utilities/dummy.dart';
import 'index.dart';

class PersistError2Model extends MomentumModel<PersistError2Controller> {
  PersistError2Model(
    PersistError2Controller controller, {
    this.data,
  }) : super(controller);

  final DummyObject data;

  @override
  void update({
    DummyObject data,
  }) {
    PersistError2Model(
      controller,
      data: data ?? this.data,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toMap() {
    var decoded = jsonDecode(jsonEncode(data));
    return {
      'data': decoded,
    };
  }

  @override
  PersistError2Model fromMap(Map<String, dynamic> json) {
    throw FormatException();
  }
}
