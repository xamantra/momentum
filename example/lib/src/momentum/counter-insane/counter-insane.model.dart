import 'package:momentum/momentum.dart';

import 'counter-insane.controller.dart';
import '../../../src/momentum/counter-advance/counter-advance.model.dart';

class CounterInsaneModel extends MomentumModel<CounterInsaneController> {
  final List<CounterItem> items;
  final bool nameInputError;
  final String nameInputErrorMessage;
  final bool counterExceedError;
  final String counterExceedMessage;

  CounterInsaneModel(
    CounterInsaneController controller, {
    this.items,
    this.nameInputError,
    this.nameInputErrorMessage,
    this.counterExceedError,
    this.counterExceedMessage,
  }) : super(controller);

  @override
  void update({
    List<CounterItem> items,
    bool nameInputError,
    String nameInputErrorMessage,
    bool counterExceedError,
    String counterExceedMessage,
  }) {
    CounterInsaneModel(
      controller,
      items: items ?? this.items,
      nameInputError: nameInputError ?? this.nameInputError,
      nameInputErrorMessage: nameInputErrorMessage ?? this.nameInputErrorMessage,
      counterExceedError: counterExceedError ?? this.counterExceedError,
      counterExceedMessage: counterExceedMessage ?? this.counterExceedMessage,
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
