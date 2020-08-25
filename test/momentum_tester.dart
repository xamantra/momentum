import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';
import 'package:momentum/src/momentum_base.dart';
import 'package:momentum/src/momentum_error.dart';

import 'components/counter/counter.controller.dart';
import 'components/dummy/dummy.controller.dart';
import 'components/router-param/index.dart';
import 'utilities/dummy.dart';
import 'widgets/inject_service.dart';
import 'widgets/router_params.dart';

void main() {
  test('Momentum Tester Tool: Counter', () async {
    var tester = MomentumTester(
      Momentum(controllers: [CounterController()]),
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

  test('Momentum Tester Tool: mockLazyBootstrap', () async {
    var tester = MomentumTester(
      Momentum(controllers: [DummyController()]),
    );

    await tester.init();

    var controller = tester.controller<DummyController>();
    await tester.mockLazyBootstrap<DummyController>();
    expect(controller.model.value, 'hello world!');
  });

  test('Momentum Tester Tool: Router Param', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          RouterParamController(),
        ],
        services: [
          Router([]),
        ],
      ),
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
      Momentum(
        controllers: [
          DummyController(),
          CounterController(),
        ],
      ),
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

  test('Momentum Tester Tool: MomentumController.getService<T>()', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          DummyService(),
          DummyService2(),
        ],
      ),
    );

    await tester.init();

    var service = tester.service<DummyService>();
    var service2 = tester.service<DummyService2>();
    var sum = service2.sum(2, 2);
    expect(sum, 4);
    var difference = service.difference(4, 2);
    expect(difference, 2);
  });

  test('Momentum Tester Tool: MomentumService.getService<T>()', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          DummyController(),
        ],
        services: [
          DummyService(),
        ],
      ),
    );

    await tester.init();

    var dummy = tester.controller<DummyController>();
    expect(dummy, isInstanceOf<DummyController>());
    var sum = dummy.getSum(10, 11);
    expect(sum, 21);
  });

  test('Momentum Tester Tool: InjectService', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          InjectService(CalcAlias.disableLogs, CalculatorService()),
          InjectService(
            CalcAlias.enableLogs,
            CalculatorService(
              enableLogs: true,
            ),
          ),
          DummyService(),
        ],
      ),
    );

    await tester.init();

    var calculatorWithoutLogs = tester.service<CalculatorService>();
    expect(calculatorWithoutLogs.enableLogs, false);
    var calculatorWithLogs = tester.service<CalculatorService>(
      alias: CalcAlias.enableLogs,
    );
    expect(calculatorWithLogs.enableLogs, true);
    calculatorWithoutLogs = tester.service<CalculatorService>(
      alias: CalcAlias.disableLogs,
    );
    expect(calculatorWithoutLogs.enableLogs, false);
  });

  test('Momentum Tester Tool: Init Error test.', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          DummyPersistedController(errorTest: true)..config(lazy: false),
        ],
      ),
    );

    try {
      await tester.init();
      expect(false, true); // force fail. this unit test should throw an error.
    } on dynamic catch (e) {
      expect(e, isA<MomentumError>());
    }
    var controller = tester.controller<DummyController>();
    expect(controller, null);
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

  test('Momentum Tester Tool: InMemoryStorage', () async {
    var tester = MomentumTester(Momentum(controllers: []));
    await tester.init();
    var storage = tester.service<InMemoryStorage>();
    storage.setString('mock-test', 'hello world');
    expect(storage.getString('mock-test'), 'hello world');
  });

  test('Momentum Tester Tool: Service Error Test', () async {
    var tester = MomentumTester(
      Momentum(controllers: [], services: [DummyService()]),
    );
    await tester.init();
    try {
      tester.service<CalculatorService>();
      expect(false, true); // force fail, this test should throw an error.
    } on dynamic catch (e) {
      expect(e, isA<MomentumError>());
    }
    try {
      tester.service<InjectService>();
      expect(false, true); // force fail, this test should throw an error.
    } on dynamic catch (e) {
      expect(e, isA<MomentumError>());
    }
    try {
      tester.service<InjectService<dynamic>>();
      expect(false, true); // force fail, this test should throw an error.
    } on dynamic catch (e) {
      expect(e, isA<MomentumError>());
    }
    try {
      tester.service<DummyService>(alias: 'none');
      expect(false, true); // force fail, this test should throw an error.
    } on dynamic catch (e) {
      expect(e, isA<MomentumError>());
    }
  });
}

MomentumTester persistedTester() {
  return MomentumTester(
    Momentum(
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
    ),
  );
}
