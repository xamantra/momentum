import 'package:momentum/momentum.dart';

import 'index.dart';

class CalculatorController extends MomentumController<CalculatorModel> {
  @override
  CalculatorModel init() {
    return CalculatorModel(
      this,
      // TODO: specify initial values here...
    );
  }
}
