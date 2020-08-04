import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';
import 'package:momentum/src/momentum_base.dart';

import 'components/counter/counter.controller.dart';
import 'components/dummy/dummy.controller.dart';
import 'components/router-param/index.dart';
import 'utilities/dummy.dart';
import 'widgets/router_params.dart';

void main() {
  test('Momentum Tester Tool: Counter', () async {
    var tester = MomentumTester(
      controllers: [
        CounterController(),
      ],
    );

    await tester.init();

    var counter = tester.controller<CounterController>();
    expect(counter != null, true);
    expect(counter, isInstanceOf<CounterController>());
    expect(counter.model.value, 0);
    counter.increment();
    expect(counter.model.value, 1);
    counter.increment();
    counter.increment();
    counter.increment();
    expect(counter.model.value, 4);
    counter.decrement();
    expect(counter.model.value, 3);
  });

  test('Momentum Tester Tool: Router Param', () async {
    var tester = MomentumTester(
      controllers: [
        RouterParamController(),
      ],
      services: [
        Router([]),
      ],
    );

    await tester.init();

    var controller = tester.controller<RouterParamController>();
    expect(controller != null, true);
    expect(controller, isInstanceOf<RouterParamController>());
    tester.mockRouterParam(TestRouterParamsC('tester...'));
    var paramValue = controller.getParamValue();
    expect(paramValue, 'tester...');
    var paramErrorTest = controller.getParamErrorTest();
    expect(paramErrorTest, null);
  });

  test('Momentum Tester Tool: dependOn<T>()', () async {
    var tester = MomentumTester(
      controllers: [
        DummyController(),
        CounterController(),
      ],
    );

    await tester.init();

    var dummy = tester.controller<DummyController>();
    var counter = tester.controller<CounterController>();
    expect(dummy, isInstanceOf<DummyController>());
    expect(counter, isInstanceOf<CounterController>());
    expect(dummy.getCounterValue(), 0);
    counter.increment();
    counter.increment();
    expect(dummy.getCounterValue(), 2);
  });

  test('Momentum Tester Tool: getService<T>()', () async {
    var tester = MomentumTester(
      controllers: [
        DummyController(),
      ],
      services: [
        DummyService(),
      ],
    );

    await tester.init();

    var dummy = tester.controller<DummyController>();
    expect(dummy, isInstanceOf<DummyController>());
    var sum = dummy.getSum(10, 11);
    expect(sum, 21);
  });

  test('Momentum Tester Tool: Persistent State', () async {
    var tester = persistedTester();
    await tester.init();

    var counter = tester.controller<DummyPersistedController>();
    expect(counter != null, true);
    expect(counter, isInstanceOf<DummyPersistedController>());
    expect(counter.model.counter, 0);
    counter.increment();
    expect(counter.model.counter, 1);
    counter.increment();
    counter.increment();
    counter.increment();
    expect(counter.model.counter, 4);

    var restartedTester = persistedTester();
    await restartedTester.init();
    counter = restartedTester.controller<DummyPersistedController>();
    expect(counter.model.counter, 4);
  });
}

MomentumTester persistedTester() {
  return MomentumTester(
    controllers: [
      DummyPersistedController(),
    ],
    services: [
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('Momentum Tester Tool', null);
      var result = storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('Momentum Tester Tool', null);
      var result = storage.getString(key);
      return result;
    },
  );
}
