import 'package:momentum/momentum.dart';

import '../../utilities/sleep.dart';
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
  Future<void> bootstrapAsync() async {
    await sleep(1500);
    model.update(value: 22, name: 'flutter is best');
  }

  @override
  Future<bool> skipPersist() async => true;
}
