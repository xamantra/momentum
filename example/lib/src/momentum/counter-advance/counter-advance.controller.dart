import 'package:momentum/momentum.dart';

import 'counter-advance.model.dart';

class CounterAdvanceController extends MomentumController<CounterAdvanceModel> {
  @override
  CounterAdvanceModel init() {
    return CounterAdvanceModel(
      this,
      value: 0,
      action: CounterAdvanceAction.Increment,
    );
  }

  void dispatchAction() {
    switch (model.action) {
      case CounterAdvanceAction.Increment:
        model.update(value: model.value + 1);
        break;
      case CounterAdvanceAction.Decrement:
        model.update(value: model.value - 1);
        break;
      default:
        break;
    }
  }

  void toggleAction() {
    if (model.action == CounterAdvanceAction.Increment) {
      model.update(action: CounterAdvanceAction.Decrement);
    } else {
      model.update(action: CounterAdvanceAction.Increment);
    }
  }
}
