import 'package:momentum/momentum.dart';

import 'index.dart';

class DummyController extends MomentumController<DummyModel> {
  @override
  DummyModel init() {
    return DummyModel(
      this,
      value: 0,
    );
  }
}
