import 'package:momentum/momentum.dart';

import 'index.dart';

class TypeTestModel extends MomentumModel<TypeTestController> {
  TypeTestModel(
    TypeTestController controller, {
    this.value,
  }) : super(controller);

  final int value;

  @override
  void update({
    int value,
  }) {
    TypeTestModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}
