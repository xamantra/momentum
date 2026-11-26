import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/dummy/index.dart';
import '../demo_app/components/rest-api-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/services/api-service.dart';
import '../demo_app/services/dummy-service.dart';

void main() {
  testWidgets('test `persistentStateDisabled`', (tester) async {
    var basicListCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        disabledPersistentState: true,
        controllers: [basicListCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(basicListCtrl.persistentStateDisabled, true);

    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        disabledPersistentState: false,
        controllers: [todoCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(todoCtrl.persistentStateDisabled, false);

    var restCtrl = RestApiExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        controllers: [restCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(restCtrl.persistentStateDisabled, false);
  });

  testWidgets('test `loggingEnabled`', (tester) async {
    var basicListCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        enableLogging: true,
        controllers: [basicListCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(basicListCtrl.loggingEnabled, true);

    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        enableLogging: false,
        controllers: [todoCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(todoCtrl.loggingEnabled, false);

    var restCtrl = RestApiExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        controllers: [restCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(restCtrl.loggingEnabled, false);
  });

  testWidgets('test `maxTimeTravelSteps`', (tester) async {
    var basicListCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        maxTimeTravelSteps: 5,
        controllers: [basicListCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(basicListCtrl.maxTimeTravelSteps, 5);

    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        maxTimeTravelSteps: 1,
        controllers: [todoCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(todoCtrl.maxTimeTravelSteps, 1);

    var restCtrl = RestApiExampleController();
    await tester.pumpWidget(
      Momentum(
        key: UniqueKey(),
        child: MaterialApp(home: Scaffold()),
        maxTimeTravelSteps: 0, // 1 is the minimum. can't be bypass
        controllers: [restCtrl],
      ),
    );
    await tester.pumpAndSettle();
    expect(restCtrl.maxTimeTravelSteps, 1);
  });

  testWidgets('test duplicate controllers', (tester) async {
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [
          BasicListExampleController(),
          BasicListExampleController(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test duplicate InjectService', (tester) async {
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        services: [
          InjectService('srv', ApiService()),
          InjectService('srv', DummyService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test missing controllers with context', (tester) async {
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Momentum.controller<BasicListExampleController>(context);
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [TodoExampleController()],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test inject service with context', (tester) async {
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Momentum.service<InjectService>(context);
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [
          InjectService('srv1', ApiService()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());

    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Momentum.service<InjectService<dynamic>>(context);
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [
          InjectService('srv1', ApiService()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test inject service with context (targeted type)', (tester) async {
    ApiService? apiService;
    DummyService? dummyService;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                apiService = Momentum.service<ApiService>(context);
                dummyService = Momentum.service<DummyService>(context);
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [
          InjectService('srv1', ApiService()),
          DummyService(),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
    expect(apiService != null, true);
    expect(dummyService != null, true);
  });

  testWidgets('test inject service with context and alias (target type)', (tester) async {
    DummyService? dummyService;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                dummyService = Momentum.service<DummyService>(context, alias: 'srv2');
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [
          InjectService('srv1', ApiService()),
          InjectService('srv2', DummyService(77)),
          InjectService('srv3', DummyService(88)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
    expect(dummyService != null, true);
    expect(dummyService!.value, 77);
  });

  testWidgets('test missing service with context', (tester) async {
    DummyService? dummyService;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                dummyService = Momentum.service<DummyService>(context);
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [ApiService()],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
    expect(dummyService == null, true);
  });

  testWidgets('test missing service with context and alias', (tester) async {
    DummyService? dummyService;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                dummyService = Momentum.service<DummyService>(context, alias: 'srv2');
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [],
        services: [InjectService('srv1', DummyService())],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
    expect(dummyService == null, true);
  });

  testWidgets('test missing controller in MomentumBuilder', (tester) async {
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [BasicListExampleController],
              builder: (context, snapshot) {
                return SizedBox();
              },
            ),
          ),
        ),
        controllers: [TodoExampleController()],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test bootstrap\'s lazyFirstCall parameter', (tester) async {
    var basicCtrl = BasicListExampleController()..config(strategy: BootstrapStrategy.lazyFirstCall);
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                var controller = Momentum.controller<BasicListExampleController>(context);
                return Text('${controller.value}, ${controller.value2}');
              },
            ),
          ),
        ),
        controllers: [basicCtrl],
      ),
    );
    await tester.pumpAndSettle();

    expect(basicCtrl.value, 99);
    expect(basicCtrl.value2, 88);

    var text = find.text('99, 88');
    expect(text, findsOneWidget);
  });

  test('test lazy controllers with MomentumTester', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [BasicListExampleController()],
      ),
    );
    await tester.init();

    await tester.mockLazyBootstrap<BasicListExampleController>();

    var controller = tester.controller<BasicListExampleController>()!;
    expect(controller.value, 99);
    expect(controller.value2, 88);
  });

  test('test non-lazy controllers with MomentumTester', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          BasicListExampleController()..config(lazy: false),
          DummyController(),
        ],
      ),
    );
    await tester.init();

    var controller = tester.controller<BasicListExampleController>()!;
    expect(controller.value, 99);
    expect(controller.value2, 88);

    var dummy = tester.controller<DummyController>()!;
    expect(dummy.dummyValue, 99);
  });

  group('controller config() overrides and second config() no-op', () {
    testWidgets('controller config() overrides all Momentum root parameters in both directions', (tester) async {
      final overrideCtrl = _ConfigOverrideControllerA()
        ..config(
          enableLogging: false,
          maxTimeTravelSteps: 5,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
        );
      final inheritCtrl = _ConfigOverrideControllerB();

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          enableLogging: true,
          maxTimeTravelSteps: 10,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
          controllers: [overrideCtrl, inheritCtrl],
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      // overrideCtrl keeps its config() values and eagerly bootstraps because lazy: false.
      expect(overrideCtrl.loggingEnabled, isFalse);
      expect(overrideCtrl.maxTimeTravelSteps, 5);
      expect(overrideCtrl.isLazy, isFalse);
      expect(overrideCtrl.strategy, BootstrapStrategy.lazyFirstCall);
      expect(overrideCtrl.bootstrapCount, 1);
      expect(overrideCtrl.bootstrapAsyncCount, 1);

      // inheritCtrl inherits Momentum root values and remains lazy.
      expect(inheritCtrl.loggingEnabled, isTrue);
      expect(inheritCtrl.maxTimeTravelSteps, 10);
      expect(inheritCtrl.isLazy, isTrue);
      expect(inheritCtrl.strategy, BootstrapStrategy.lazyFirstBuild);
      expect(inheritCtrl.bootstrapCount, 0);
      expect(inheritCtrl.bootstrapAsyncCount, 0);

      // Reverse direction: root lazy: false, controller overrides to lazy: true.
      final lazyOverrideCtrl = _ConfigOverrideControllerA()
        ..config(
          enableLogging: true,
          maxTimeTravelSteps: 20,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
        );
      final eagerInheritCtrl = _ConfigOverrideControllerB();

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          enableLogging: false,
          maxTimeTravelSteps: 2,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
          controllers: [lazyOverrideCtrl, eagerInheritCtrl],
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(lazyOverrideCtrl.loggingEnabled, isTrue);
      expect(lazyOverrideCtrl.maxTimeTravelSteps, 20);
      expect(lazyOverrideCtrl.isLazy, isTrue);
      expect(lazyOverrideCtrl.strategy, BootstrapStrategy.lazyFirstBuild);
      expect(lazyOverrideCtrl.bootstrapCount, 0);
      expect(lazyOverrideCtrl.bootstrapAsyncCount, 0);

      expect(eagerInheritCtrl.loggingEnabled, isFalse);
      expect(eagerInheritCtrl.maxTimeTravelSteps, 2);
      expect(eagerInheritCtrl.isLazy, isFalse);
      expect(eagerInheritCtrl.strategy, BootstrapStrategy.lazyFirstCall);
      expect(eagerInheritCtrl.bootstrapCount, 1);
      expect(eagerInheritCtrl.bootstrapAsyncCount, 1);
    });

    testWidgets('partial controller config() overrides only specified options and inherits others', (tester) async {
      final ctrl = _ConfigOverrideControllerA()..config(maxTimeTravelSteps: 7);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          enableLogging: true,
          maxTimeTravelSteps: 25,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
          controllers: [ctrl],
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(ctrl.maxTimeTravelSteps, 7);
      expect(ctrl.loggingEnabled, isTrue);
      expect(ctrl.isLazy, isFalse);
      expect(ctrl.strategy, BootstrapStrategy.lazyFirstCall);
      expect(ctrl.bootstrapCount, 1);
    });

    testWidgets('config() and Momentum root clamp maxTimeTravelSteps between 1 and 250', (tester) async {
      final ctrlLow = _ConfigOverrideControllerA()..config(maxTimeTravelSteps: -5);
      final ctrlHigh = _ConfigOverrideControllerB()..config(maxTimeTravelSteps: 999);
      final ctrlRootHigh = _ConfigOverrideControllerC();

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          maxTimeTravelSteps: 500,
          controllers: [ctrlLow, ctrlHigh, ctrlRootHigh],
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(ctrlLow.maxTimeTravelSteps, 1);
      expect(ctrlHigh.maxTimeTravelSteps, 250);
      expect(ctrlRootHigh.maxTimeTravelSteps, 250);
    });

    testWidgets('second config() call is a no-op before and after initialization (full and partial)', (tester) async {
      // Case 1: Full first config(), second config() attempts to change all values.
      final ctrlFull = _ConfigOverrideControllerA()
        ..config(
          enableLogging: true,
          maxTimeTravelSteps: 12,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
        )
        ..config(
          enableLogging: false,
          maxTimeTravelSteps: 99,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
        );

      // Case 2: Partial first config() leaves other fields null; second config() must still be ignored completely.
      final ctrlPartial = _ConfigOverrideControllerB()
        ..config(maxTimeTravelSteps: 15)
        ..config(
          enableLogging: true,
          maxTimeTravelSteps: 50,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
        );

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          enableLogging: false,
          maxTimeTravelSteps: 3,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
          controllers: [ctrlFull, ctrlPartial],
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      // ctrlFull retains first config() values.
      expect(ctrlFull.loggingEnabled, isTrue);
      expect(ctrlFull.maxTimeTravelSteps, 12);
      expect(ctrlFull.isLazy, isFalse);
      expect(ctrlFull.strategy, BootstrapStrategy.lazyFirstCall);
      expect(ctrlFull.bootstrapCount, 1);

      // Calling config() again after initialization must also be a no-op.
      ctrlFull.config(
        enableLogging: false,
        maxTimeTravelSteps: 1,
        lazy: true,
        strategy: BootstrapStrategy.lazyFirstBuild,
      );
      expect(ctrlFull.loggingEnabled, isTrue);
      expect(ctrlFull.maxTimeTravelSteps, 12);
      expect(ctrlFull.isLazy, isFalse);
      expect(ctrlFull.strategy, BootstrapStrategy.lazyFirstCall);

      // ctrlPartial retains maxTimeTravelSteps from first config(), and inherits root values for the rest
      // (proving the second config() call did not populate previously null fields).
      expect(ctrlPartial.maxTimeTravelSteps, 15);
      expect(ctrlPartial.loggingEnabled, isFalse);
      expect(ctrlPartial.isLazy, isTrue);
      expect(ctrlPartial.strategy, BootstrapStrategy.lazyFirstBuild);
      expect(ctrlPartial.bootstrapCount, 0);
    });

    test('controller config() overrides and second config() no-op work with MomentumTester', () async {
      final ctrl = _ConfigOverrideControllerA()
        ..config(
          enableLogging: true,
          maxTimeTravelSteps: 8,
          lazy: false,
          strategy: BootstrapStrategy.lazyFirstCall,
        )
        ..config(
          enableLogging: false,
          maxTimeTravelSteps: 40,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
        );
      final inheritCtrl = _ConfigOverrideControllerB();

      final tester = MomentumTester(
        Momentum(
          enableLogging: false,
          maxTimeTravelSteps: 3,
          lazy: true,
          strategy: BootstrapStrategy.lazyFirstBuild,
          controllers: [ctrl, inheritCtrl],
        ),
      );
      await tester.init();

      expect(ctrl.loggingEnabled, isTrue);
      expect(ctrl.maxTimeTravelSteps, 8);
      expect(ctrl.isLazy, isFalse);
      expect(ctrl.strategy, BootstrapStrategy.lazyFirstCall);
      expect(ctrl.bootstrapCount, 1);
      expect(ctrl.bootstrapAsyncCount, 1);

      expect(inheritCtrl.loggingEnabled, isFalse);
      expect(inheritCtrl.maxTimeTravelSteps, 3);
      expect(inheritCtrl.isLazy, isTrue);
      expect(inheritCtrl.strategy, BootstrapStrategy.lazyFirstBuild);
      expect(inheritCtrl.bootstrapCount, 0);
    });
  });
}

class _ConfigOverrideModel extends MomentumModel<_ConfigOverrideControllerBase> {
  const _ConfigOverrideModel(_ConfigOverrideControllerBase controller) : super(controller);

  @override
  void update() {
    _ConfigOverrideModel(controller).updateMomentum();
  }
}

abstract class _ConfigOverrideControllerBase extends MomentumController<_ConfigOverrideModel> {
  int bootstrapCount = 0;
  int bootstrapAsyncCount = 0;

  @override
  _ConfigOverrideModel init() => _ConfigOverrideModel(this);

  @override
  void bootstrap() {
    bootstrapCount++;
  }

  @override
  Future<void> bootstrapAsync() async {
    bootstrapAsyncCount++;
  }
}

class _ConfigOverrideControllerA extends _ConfigOverrideControllerBase {}

class _ConfigOverrideControllerB extends _ConfigOverrideControllerBase {}

class _ConfigOverrideControllerC extends _ConfigOverrideControllerBase {}
