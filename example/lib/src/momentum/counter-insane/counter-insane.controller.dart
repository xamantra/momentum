import 'package:momentum/momentum.dart';

import 'counter-insane.model.dart';
import '../../../src/momentum/counter-advance/counter-advance.model.dart';

class CounterInsaneController extends MomentumController<CounterInsaneModel> {
  @override
  CounterInsaneModel init() {
    return CounterInsaneModel(
      this,
      items: [
        CounterItem(name: 'Apple', value: 0, action: CounterAdvanceAction.Increment),
      ],
      nameInputError: false,
      counterExceedError: false,
    );
  }

  void addItem() {
    var newItem = CounterItem(name: 'Apple', value: 0, action: CounterAdvanceAction.Increment);
    var items = <CounterItem>[]
      ..addAll(model.items)
      ..add(newItem);
    model.update(items: items);
  }

  void removeItem(int index) {
    var items = <CounterItem>[]..addAll(model.items);
    items.removeAt(index);
    model.update(items: items);
  }

  void toggleAction(int index) {
    var items = <CounterItem>[]..addAll(model.items);
    items[index] = items[index].toggleAction();
    model.update(items: items, counterExceedError: false);
  }

  void dispatchAction(int index) {
    if (model.items[index].value == 10) {
      model.update(counterExceedError: true, counterExceedMessage: 'Counter cannot go above 10.');
    } else if (model.items[index].value == -10) {
      model.update(counterExceedError: true, counterExceedMessage: 'Counter cannot go below -10.');
    } else {
      // As you can see from counter-extreme, we didn't do this:
      var items = <CounterItem>[]..addAll(model.items); // create new instance of List<CounterItem>.
      // this will print false.
      print('[$CounterInsaneController.dispatchAction] -> items == model.items => ${items == model.items}');
      // That's because we want to create another instance of List<CounterItem> instead of reusing the current instance from our model in order to properly implement Time Travel methods.
      // Time Travel methods check by equality of instances not by values.
      items[index] = items[index].dispatchAction();
      model.update(items: items, counterExceedError: false);
    }
  }

  bool setName(String name, int index) {
    if (name == null || name.isEmpty) {
      model.update(nameInputError: true, nameInputErrorMessage: 'Name must not be empty.');
      return false;
    }
    var items = <CounterItem>[]..addAll(model.items);
    items[index] = items[index].setName(name);
    model.update(items: items, nameInputError: false, nameInputErrorMessage: '');
    return true;
  }
}
