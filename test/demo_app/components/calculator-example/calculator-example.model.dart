import 'package:momentum/momentum.dart';

import 'index.dart';

class CalculatorExampleModel extends MomentumModel<CalculatorExampleController> {
  CalculatorExampleModel(
    CalculatorExampleController controller, {
    this.expression,
    this.result,
  }) : super(controller);

  final String? expression;
  final String? result;

  @override
  void update({
    String? expression,
    String? result,
  }) {
    CalculatorExampleModel(
      controller,
      expression: expression ?? this.expression,
      result: result ?? this.result,
    ).updateMomentum();
  }
}
