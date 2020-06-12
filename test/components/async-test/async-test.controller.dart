import 'package:momentum/momentum.dart';

import '../../utility.dart';
import 'index.dart';

class AsyncTestController extends MomentumController<AsyncTestModel> {
  @override
  AsyncTestModel init() {
    return AsyncTestModel(
      this,
      value: 0,
      name: '',
    );
  }

  @override
  void bootstrap() {
    model.update(value: 1, name: 'momentum');
  }

  @override
  Future<void> bootstrapAsync() async {
    await sleep(1500);
    model.update(value: 2, name: 'momentum2');
  }

  @override
  Future<bool> skipPersist() async => true;
}
