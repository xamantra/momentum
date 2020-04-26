import 'package:momentum/momentum.dart';

import 'counter-extreme.model.dart';
import '../../../src/momentum/counter-advance/counter-advance.model.dart';

class CounterExtremeController extends MomentumController<CounterExtremeModel> {
  @override
  CounterExtremeModel init() {
    return CounterExtremeModel(
      this,
      items: [
        CounterItem(name: 'Apple', value: 0, action: CounterAdvanceAction.Increment),
      ],
      nameInputError: false,
    );
  }

  void addItem() {
    var newItem = CounterItem(name: 'Apple', value: 0, action: CounterAdvanceAction.Increment);
    var items = model.items..add(newItem);
    model.update(items: items);
  }

  void removeItem(int index) {
    var items = model.items;
    items.removeAt(index);
    model.update(items: model.items);
  }

  void toggleAction(int index) {
    var items = model.items;
    items[index] = model.items[index].toggleAction();
    model.update(items: model.items);
  }

  void dispatchAction(int index) {
    var items = model.items;
    // this will print true.
    print('[$CounterExtremeController.dispatchAction] -> items == model.items => ${items == model.items}');
    items[index] = model.items[index].dispatchAction();
    model.update(items: model.items);
  }

  bool setName(String name, int index) {
    if (name == null || name.isEmpty) {
      model.update(nameInputError: true, nameInputErrorMessage: 'Name must not be empty.');
      return false;
    }
    var items = model.items;
    items[index] = model.items[index].setName(name);
    model.update(items: model.items, nameInputError: false, nameInputErrorMessage: '');
    return true;
  }
}
