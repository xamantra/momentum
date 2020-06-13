import 'package:momentum/momentum.dart';

import 'index.dart';

class DummyController extends MomentumController<DummyModel> {
  @override
  DummyModel init() {
    return DummyModel(
      this,
    );
  }

  @override
  Future<bool> skipPersist() async => true;
}
