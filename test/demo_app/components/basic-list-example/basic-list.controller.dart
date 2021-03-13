import 'package:momentum/momentum.dart';

import '../../services/index.dart';
import '../../widgets/pages/example-basic-list-routed/index.dart';
import 'index.dart';

class BasicListExampleController extends MomentumController<BasicListExampleModel> with RouterMixin {
  @override
  BasicListExampleModel init() {
    return BasicListExampleModel(
      this,
      list: [],
    );
  }

  var latestList = '';

  int value = 0;
  @override
  void bootstrap() {
    value = 99;
  }

  int value2 = 0;
  @override
  Future<void> bootstrapAsync() async {
    value2 = 88;
  }

  @override
  void onRouteChanged(RouterParam param) {
    var basicListParam = getParam<BasicListRouteParam>();
    if (basicListParam != null) {
      model.update(list: basicListParam.initialList);
      latestList = model.list.join(',');
    }

    getParam<DummyRouteParam>();
    super.onRouteChanged(param); // for testing only. called to cover lines in `codecov`
  }

  void addNewRandom() {
    var random = (['blue', 'green', 'red', 'yello', 'orange']..shuffle()).first;
    var list = List<String>.from(model.list); // proper way to manipulate a list.
    // var list = model.list; // wrong way to manipulate a list. undo/redo doesn't work properly.
    list.add('$random#${list.length}');
    model.update(list: list);
  }

  void add(String name) {
    var list = List<String>.from(model.list);
    list = list
      ..add(name)
      ..toSet()
      ..toList();
    model.update(list: list);
  }

  void addFromService(String name, String age) {
    var ls = service<BasicListService>();
    add(ls.addFrom(name, age));
  }

  void remove(int index) {
    var list = List<String>.from(model.list); // proper way to manipulate a list.
    // var list = model.list; // wrong way to manipulate a list. undo/redo doesn't work properly.
    list.removeAt(index);
    model.update(list: list);
  }

  void reverseListUpdate() {
    var list = List<String>.from(model.list); // proper way to manipulate a list.
    model.update(list: list.reversed.toList());
  }

  void clearListUpdate() {
    model.update(list: []);
  }

  void undo() {
    this.backward();
  }

  void redo() {
    this.forward();
  }
}

class BasicListExtendedController extends BasicListExampleController {}
