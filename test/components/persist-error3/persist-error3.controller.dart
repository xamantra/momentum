import 'package:momentum/momentum.dart';

import 'index.dart';

class PersistError3Controller extends MomentumController<PersistError3Model> {
  @override
  PersistError3Model init() {
    return PersistError3Model(
      this,
      data: DummyObject3(0),
    );
  }
}
