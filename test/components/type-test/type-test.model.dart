import 'package:momentum/momentum.dart';

import 'index.dart';

class TypeTestModel extends MomentumModel<TypeTestController> {
  TypeTestModel(
    TypeTestController controller, {
    this.value,
    this.squareRoot,
  }) : super(controller);

  final int value;
  final double squareRoot;

  @override
  void update({
    int value,
    double squareRoot,
  }) {
    TypeTestModel(
      controller,
      value: value ?? this.value,
      squareRoot: squareRoot ?? this.squareRoot,
    ).updateMomentum();
  }
}
