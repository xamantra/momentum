import 'package:momentum/momentum.dart';

import '../../utilities/dummy.dart';
import '../counter/counter.controller.dart';
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

  int getCounterValue() {
    var counter = dependOn<CounterController>();
    return counter.model.value;
  }

  double getSum(double a, double b) {
    var service = getService<DummyService>();
    return service.sum(a, b);
  }
}

class DummyPersistedController extends MomentumController<DummyPersistedModel> {
  DummyPersistedController({
    this.errorTest = false,
  });
  final bool errorTest;

  @override
  DummyPersistedModel init() {
    return DummyPersistedModel(
      this,
      counter: 0,
    );
  }

  @override
  void bootstrap() {
    if (errorTest) {
      dummyError();
    }
  }

  void increment() {
    model.update(counter: model.counter + 1);
  }

  void dummyError() {
    throw 'dummy error only for testing';
  }
}
