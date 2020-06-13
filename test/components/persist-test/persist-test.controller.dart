import 'package:momentum/momentum.dart';

import 'index.dart';

class PersistTestController extends MomentumController<PersistTestModel> {
  @override
  PersistTestModel init() {
    return PersistTestModel(
      this,
      username: '',
      email: '',
    );
  }
}
