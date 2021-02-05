import 'package:momentum/momentum.dart';
import 'package:random_words/random_words.dart';

import 'index.dart';

class BasicListExampleController extends MomentumController<BasicListExampleModel> {
  @override
  BasicListExampleModel init() {
    return BasicListExampleModel(
      this,
      list: [],
    );
  }

  void addNewRandom() {
    var random = generateNoun().take(1).first;
    var list = List<String>.from(model.list); // proper way to manipulate a list.
    // var list = model.list; // wrong way to manipulate a list. undo/redo doesn't work properly.
    list.add(random.word);
    model.update(list: list);
  }

  void remove(int index) {
    var list = List<String>.from(model.list); // proper way to manipulate a list.
    // var list = model.list; // wrong way to manipulate a list. undo/redo doesn't work properly.
    list.removeAt(index);
    model.update(list: list);
  }

  void undo() {
    this.backward();
  }

  void redo() {
    this.forward();
  }
}
