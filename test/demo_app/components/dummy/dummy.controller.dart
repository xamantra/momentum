import 'package:momentum/momentum.dart';

import '../basic-list-example/index.dart';
import 'index.dart';

class DummyController extends MomentumController<DummyModel> {
  @override
  DummyModel init() {
    return DummyModel(
      this,
      value: 0,
    );
  }

  int dummyValue = 0;

  @override
  void onReady() {
    dummyValue = controller<BasicListExampleController>().value;
  }
}
