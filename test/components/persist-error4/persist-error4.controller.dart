import 'package:momentum/momentum.dart';

import '../persist-error3/index.dart';
import 'index.dart';

class PersistError4Controller extends MomentumController<PersistError4Model> {
  @override
  PersistError4Model init() {
    return PersistError4Model(
      this,
      data: DummyObject3(0),
    );
  }
}
