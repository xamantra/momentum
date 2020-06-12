import 'package:momentum/momentum.dart';

import 'index.dart';

class CalculatorModel extends MomentumModel<CalculatorController> {
  CalculatorModel(CalculatorController controller) : super(controller);

  // TODO: add your final properties here...

  @override
  void update() {
    CalculatorModel(
      controller,
    ).updateMomentum();
  }
}
