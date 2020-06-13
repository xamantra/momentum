import 'package:momentum/momentum.dart';

import 'index.dart';

class SyncTestController extends MomentumController<SyncTestModel> {
  @override
  SyncTestModel init() {
    return SyncTestModel(
      this,
      value: 0,
      name: '',
    );
  }

  @override
  void bootstrap() {
    model.update(value: 333, name: 'flutter is awesome');
  }

  @override
  Future<bool> skipPersist() async => true;
}
