import 'package:momentum/momentum.dart';

import '../persist-error1/index.dart';
import 'index.dart';

class PersistError2Controller extends MomentumController<PersistError2Model> {
  @override
  PersistError2Model init() {
    return PersistError2Model(
      this,
      data: DummyObject(0),
    );
  }
}
