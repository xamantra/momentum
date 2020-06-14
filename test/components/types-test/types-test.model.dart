import 'package:momentum/momentum.dart';

import 'index.dart';

class TypesTestModel extends MomentumModel<TypesTestController> {
  TypesTestModel(
    TypesTestController controller, {
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
    TypesTestModel(
      controller,
      value: value ?? this.value,
      square: square ?? this.square,
    ).updateMomentum();
  }
}
