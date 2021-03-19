import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_error.dart';

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
                // ignore: deprecated_member_use_from_same_package
                dummyService = Momentum.getService<DummyService>(context);
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
}
