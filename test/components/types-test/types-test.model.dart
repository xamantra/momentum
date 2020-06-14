import 'package:momentum/momentum.dart';

import 'index.dart';

class ATypesTestModel extends MomentumModel<TypesTestCtrl> {
  ATypesTestModel(
    TypesTestCtrl controller, {
    this.value,
    this.square,
  }) : super(controller);

  final int value;
  final int square;

  @override
  void update({
    int value,
    int square,
  }) {
    ATypesTestModel(
      controller,
      value: value ?? this.value,
      square: square ?? this.square,
    ).updateMomentum();
  }
}
