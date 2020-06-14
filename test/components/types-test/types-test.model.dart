import 'package:momentum/momentum.dart';

import 'index.dart';

class TypesTestModel extends MomentumModel<TypesTestController> {
  TypesTestModel(
    TypesTestController controller, {
    this.value,
    this.squareRoot,
  }) : super(controller);

  final int value;
  final int squareRoot;

  @override
  void update({
    int value,
    int squareRoot,
  }) {
    TypesTestModel(
      controller,
      value: value ?? this.value,
      squareRoot: squareRoot ?? this.squareRoot,
    ).updateMomentum();
  }
}
