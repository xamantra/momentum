import 'package:momentum/momentum.dart';

import 'index.dart';

class TypeTestModel extends MomentumModel<TypeTestController> {
  TypeTestModel(
    TypeTestController controller, {
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
    TypeTestModel(
      controller,
      value: value ?? this.value,
      squareRoot: squareRoot ?? this.squareRoot,
    ).updateMomentum();
  }
}
