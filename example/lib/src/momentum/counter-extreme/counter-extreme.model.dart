import 'package:momentum/momentum.dart';

import '../../../src/momentum/counter-advance/counter-advance.model.dart';
import 'counter-extreme.controller.dart';

class CounterExtremeModel extends MomentumModel<CounterExtremeController> {
  final List<CounterItem> items;
  final bool nameInputError;
  final String nameInputErrorMessage;

  CounterExtremeModel(
    CounterExtremeController controller, {
    this.items,
    this.nameInputError,
    this.nameInputErrorMessage,
  }) : super(controller);

  @override
  void update({
    List<CounterItem> items,
    bool nameInputError,
    String nameInputErrorMessage,
  }) {
    CounterExtremeModel(
      controller,
      items: items ?? this.items,
      nameInputError: nameInputError ?? this.nameInputError,
      nameInputErrorMessage: nameInputErrorMessage ?? this.nameInputErrorMessage,
    ).updateMomentum();
  }
}

class CounterItem {
  final String name;
  final int value;
  final CounterAdvanceAction action;

  CounterItem({this.name, this.value, this.action});

  CounterItem setName(String name) {
    return CounterItem(name: name, value: value, action: action);
  }

  CounterItem toggleAction() {
    var newAction = action == CounterAdvanceAction.Increment ? CounterAdvanceAction.Decrement : CounterAdvanceAction.Increment;
    return CounterItem(name: name, value: value, action: newAction);
  }

  CounterItem dispatchAction() {
    var newValue = value;
    switch (action) {
      case CounterAdvanceAction.Increment:
        newValue++;
        break;
      case CounterAdvanceAction.Decrement:
        newValue--;
        break;
      default:
        break;
    }
    return CounterItem(name: name, value: newValue, action: action);
  }
}
