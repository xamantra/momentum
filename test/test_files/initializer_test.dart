import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_event.dart';

class _TrackingRouter extends MomentumRouter {
  MomentumEvent? capturedEvent;

  _TrackingRouter(List<Widget> pages) : super(pages);

  @override
  void setFunctions(
    BuildContext context,
    PersistSaver? persistSaver,
    PersistGet? persistGet,
    MomentumEvent? momentumEvent,
  ) {
    capturedEvent = momentumEvent;
    super.setFunctions(context, persistSaver, persistGet, momentumEvent);
  }
}

class _RouteCountingModel extends MomentumModel<_RouteCountingController> {
  const _RouteCountingModel(_RouteCountingController controller) : super(controller);

  @override
  void update() {
    _RouteCountingModel(controller).updateMomentum();
  }
}

class _RouteCountingController extends MomentumController<_RouteCountingModel> with RouterMixin {
  int routeChangeCount = 0;

  @override
  _RouteCountingModel init() => _RouteCountingModel(this);

  @override
  void onRouteChanged(RouterParam? param) {
    routeChangeCount++;
  }
}

class _PageA extends StatelessWidget {
  const _PageA();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('PageA'));
}

class _PageB extends StatelessWidget {
  const _PageB();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('PageB'));
}

class _OrderService extends MomentumService {
  final String tag;
  _OrderService(this.tag);
}

class _OrderRouter extends MomentumRouter {
  final List<String> log;
  final Completer<void>? initGate;

  _OrderRouter(
    List<Widget> pages, {
    required this.log,
    this.initGate,
  }) : super(pages);

  @override
  Future<void> init() async {
    log.add('services:routerInit:start');
    if (initGate != null) {
      await initGate!.future;
    }
    await super.init();
    log.add('services:routerInit:end');
  }
}

class _OrderModel extends MomentumModel<_OrderControllerBase> {
  const _OrderModel(_OrderControllerBase controller) : super(controller);

  @override
  void update() {
    _OrderModel(controller).updateMomentum();
  }
}

abstract class _OrderControllerBase extends MomentumController<_OrderModel> {
  final String name;
  final List<String> log;
  final Completer<void>? asyncGate;
  final void Function()? onInitCheck;

  _OrderControllerBase({
    required this.name,
    required this.log,
    this.asyncGate,
    this.onInitCheck,
  });

  @override
  _OrderModel init() {
    log.add('$name:init');
    onInitCheck?.call();
    return _OrderModel(this);
  }

  @override
  void bootstrap() {
    log.add('$name:bootstrap');
  }

  @override
  Future<void> bootstrapAsync() async {
    log.add('$name:bootstrapAsync:start');
    if (asyncGate != null) {
      await asyncGate!.future;
    }
    log.add('$name:bootstrapAsync:end');
  }

  @override
  void onReady() {
    log.add('$name:onReady');
  }
}

class _OrderControllerA extends _OrderControllerBase {
  _OrderControllerA({
    required List<String> log,
    Completer<void>? asyncGate,
    void Function()? onInitCheck,
  }) : super(
          name: 'A',
          log: log,
          asyncGate: asyncGate,
          onInitCheck: onInitCheck,
        );
}

class _OrderControllerB extends _OrderControllerBase {
  _OrderControllerB({
    required List<String> log,
    Completer<void>? asyncGate,
  }) : super(
          name: 'B',
          log: log,
          asyncGate: asyncGate,
        );
}

class _LazyOrderController extends _OrderControllerBase {
  _LazyOrderController({
    required List<String> log,
  }) : super(
          name: 'Lazy',
          log: log,
        );
}

void main() {
  testWidgets('test Momentum\'s `initializer` parameter', (tester) async {
    var value = 0;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        initializer: () async {
          value = 99;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(value, 99);
  });

  testWidgets('test Momentum\'s `initializer` parameter with error', (tester) async {
    var value = 0;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        initializer: () async {
          value = int.parse('dwdw');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(value, 0);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  test('test Momentum\'s `initializer` parameter with MomentumTester', () async {
    var value = 0;
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        initializer: () async {
          value = 99;
        },
      ),
    );
    await tester.init();

    expect(value, 99);
  });

  test('test Momentum\'s `initializer` parameter error with MomentumTester', () async {
    var value = 0;
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        initializer: () async {
          value = int.parse('dwdw');
        },
      ),
    );

    await expectLater(tester.init(), throwsA(isA<MomentumError>()));

    expect(value, 0);
  });

  testWidgets('Momentum does not re-run initializer or duplicate router listeners on rebuild and destroys event on dispose', (tester) async {
    var initCount = 0;
    late StateSetter rebuildParent;
    var controller = _RouteCountingController();
    var router = MomentumRouter([const _PageA(), const _PageB()]);
    var trackingRouter = _TrackingRouter([const _PageA(), const _PageB()]);
    late BuildContext navContext;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuildParent = setState;
          return Momentum(
            controllers: [controller],
            services: [router, trackingRouter],
            initializer: () async {
              initCount++;
            },
            child: MaterialApp(
              home: Builder(
                builder: (ctx) {
                  navContext = ctx;
                  return MomentumRouter.getActivePage(ctx);
                },
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(initCount, 1);
    expect(trackingRouter.capturedEvent, isNotNull);
    expect(trackingRouter.capturedEvent!.streamController.isClosed, isFalse);

    // Trigger multiple parent rebuilds.
    rebuildParent(() {});
    await tester.pumpAndSettle();
    rebuildParent(() {});
    await tester.pumpAndSettle();
    rebuildParent(() {});
    await tester.pumpAndSettle();

    expect(initCount, 1);

    // Navigating once should notify RouterMixin controllers exactly once.
    MomentumRouter.goto(navContext, _PageB);
    await tester.pumpAndSettle();
    expect(controller.routeChangeCount, 1);
    expect(find.text('PageB'), findsOneWidget);

    // Disposing Momentum must destroy the internal MomentumEvent.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(trackingRouter.capturedEvent!.streamController.isClosed, isTrue);
  });

  testWidgets('Momentum does not retry initializer infinitely on error across rebuilds', (tester) async {
    var initCount = 0;
    late StateSetter rebuildParent;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuildParent = setState;
          return Momentum(
            controllers: [],
            initializer: () async {
              initCount++;
              throw StateError('init failure');
            },
            child: const MaterialApp(home: Scaffold()),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(initCount, 1);
    expect(tester.takeException(), isInstanceOf<MomentumError>());

    // Subsequent parent rebuilds must not re-run _init() or loop on error.
    rebuildParent(() {});
    await tester.pumpAndSettle();
    rebuildParent(() {});
    await tester.pumpAndSettle();

    expect(initCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Momentum unmounted during async initializer exits cleanly without leaking event', (tester) async {
    var completer = Completer<void>();
    var router = _TrackingRouter([const _PageA()]);

    await tester.pumpWidget(
      Momentum(
        controllers: [],
        services: [router],
        initializer: () => completer.future,
        child: const MaterialApp(home: Scaffold()),
      ),
    );
    await tester.pump();

    // Unmount before initializer completes.
    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete();
    await tester.pumpAndSettle();

    expect(router.capturedEvent, isNull);
    expect(tester.takeException(), isNull);
  });

  group('initialization order, appLoader & minimumBootstrapTime', () {
    testWidgets('strict lifecycle order: initializer -> services -> init -> bootstrap -> parallel bootstrapAsync -> onReady', (tester) async {
      final log = <String>[];
      final initGate = Completer<void>();
      final serviceGate = Completer<void>();
      final gateA = Completer<void>();
      final gateB = Completer<void>();

      final orderService = _OrderService('ready-service');
      _OrderService? resolvedInInit;

      late final _OrderControllerA ctrlA;
      ctrlA = _OrderControllerA(
        log: log,
        asyncGate: gateA,
        onInitCheck: () {
          resolvedInInit = ctrlA.service<_OrderService>();
        },
      )..config(lazy: false);
      final ctrlB = _OrderControllerB(
        log: log,
        asyncGate: gateB,
      )..config(lazy: false);
      final ctrlLazy = _LazyOrderController(log: log);
      final router = _OrderRouter(
        [const _PageA()],
        log: log,
        initGate: serviceGate,
      );

      await tester.pumpWidget(
        Momentum(
          initializer: () async {
            log.add('initializer:start');
            await initGate.future;
            log.add('initializer:end');
          },
          services: [orderService, router],
          controllers: [ctrlA, ctrlB, ctrlLazy],
          appLoader: const MaterialApp(home: Scaffold(body: Text('CustomLoading'))),
          child: const MaterialApp(home: Scaffold(body: Text('AppReady'))),
        ),
      );
      await tester.pump();

      // Step 1: Only initializer has started; loader is visible.
      expect(log, ['initializer:start']);
      expect(find.text('CustomLoading'), findsOneWidget);
      expect(find.text('AppReady'), findsNothing);

      // Step 2: Finish initializer -> services initialize next and await router.init().
      initGate.complete();
      await tester.pump();
      expect(log, [
        'initializer:start',
        'initializer:end',
        'services:routerInit:start',
      ]);
      expect(resolvedInInit, isNull);

      // Step 3: Finish service init -> all init() -> non-lazy bootstrap() -> parallel bootstrapAsync().
      serviceGate.complete();
      await tester.pump();
      expect(resolvedInInit, same(orderService));
      expect(log, [
        'initializer:start',
        'initializer:end',
        'services:routerInit:start',
        'services:routerInit:end',
        'A:init',
        'B:init',
        'Lazy:init',
        'A:bootstrap',
        'B:bootstrap',
        'A:bootstrapAsync:start',
        'B:bootstrapAsync:start',
      ]);
      expect(find.text('CustomLoading'), findsOneWidget);
      expect(find.text('AppReady'), findsNothing);

      // Step 4: Complete B before A to prove parallel execution; onReady must still wait for A.
      gateB.complete();
      await tester.pump();
      expect(log, [
        'initializer:start',
        'initializer:end',
        'services:routerInit:start',
        'services:routerInit:end',
        'A:init',
        'B:init',
        'Lazy:init',
        'A:bootstrap',
        'B:bootstrap',
        'A:bootstrapAsync:start',
        'B:bootstrapAsync:start',
        'B:bootstrapAsync:end',
      ]);
      expect(find.text('CustomLoading'), findsOneWidget);
      expect(find.text('AppReady'), findsNothing);

      // Step 5: Complete A -> all controllers (including lazy) receive onReady, then child renders.
      gateA.complete();
      await tester.pumpAndSettle();
      expect(log, [
        'initializer:start',
        'initializer:end',
        'services:routerInit:start',
        'services:routerInit:end',
        'A:init',
        'B:init',
        'Lazy:init',
        'A:bootstrap',
        'B:bootstrap',
        'A:bootstrapAsync:start',
        'B:bootstrapAsync:start',
        'B:bootstrapAsync:end',
        'A:bootstrapAsync:end',
        'A:onReady',
        'B:onReady',
        'Lazy:onReady',
      ]);
      expect(find.text('CustomLoading'), findsNothing);
      expect(find.text('AppReady'), findsOneWidget);
    });

    test('strict lifecycle order with MomentumTester including parallel bootstrapAsync', () async {
      final log = <String>[];
      final initGate = Completer<void>();
      final gateA = Completer<void>();
      final gateB = Completer<void>();

      final orderService = _OrderService('tester-service');
      _OrderService? resolvedInInit;

      late final _OrderControllerA ctrlA;
      ctrlA = _OrderControllerA(
        log: log,
        asyncGate: gateA,
        onInitCheck: () {
          resolvedInInit = ctrlA.service<_OrderService>();
        },
      )..config(lazy: false);
      final ctrlB = _OrderControllerB(
        log: log,
        asyncGate: gateB,
      )..config(lazy: false);
      final ctrlLazy = _LazyOrderController(log: log);

      final tester = MomentumTester(
        Momentum(
          initializer: () async {
            log.add('initializer:start');
            await initGate.future;
            log.add('initializer:end');
          },
          services: [orderService],
          controllers: [ctrlA, ctrlB, ctrlLazy],
        ),
      );

      final initFuture = tester.init();
      await Future<void>.delayed(Duration.zero);
      expect(log, ['initializer:start']);

      initGate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(resolvedInInit, same(orderService));
      expect(log, [
        'initializer:start',
        'initializer:end',
        'A:init',
        'B:init',
        'Lazy:init',
        'A:bootstrap',
        'B:bootstrap',
        'A:bootstrapAsync:start',
        'B:bootstrapAsync:start',
      ]);

      gateB.complete();
      await Future<void>.delayed(Duration.zero);
      expect(log.last, 'B:bootstrapAsync:end');
      expect(log, isNot(contains('A:onReady')));

      gateA.complete();
      await initFuture;
      expect(log, [
        'initializer:start',
        'initializer:end',
        'A:init',
        'B:init',
        'Lazy:init',
        'A:bootstrap',
        'B:bootstrap',
        'A:bootstrapAsync:start',
        'B:bootstrapAsync:start',
        'B:bootstrapAsync:end',
        'A:bootstrapAsync:end',
        'A:onReady',
        'B:onReady',
        'Lazy:onReady',
      ]);
    });

    testWidgets('custom appLoader is displayed during bootstrapAsync and held for minimumBootstrapTime', (tester) async {
      final log = <String>[];
      final gate = Completer<void>();
      final ctrl = _OrderControllerA(log: log, asyncGate: gate)..config(lazy: false);

      await tester.pumpWidget(
        Momentum(
          controllers: [ctrl],
          minimumBootstrapTime: 1000,
          appLoader: const MaterialApp(
            home: Scaffold(body: Text('Custom Splash Loader')),
          ),
          child: const MaterialApp(
            home: Scaffold(body: Text('Main App Screen')),
          ),
        ),
      );
      await tester.pump();

      // Custom appLoader shown while bootstrapAsync is pending (default CircularProgressIndicator not rendered).
      expect(find.text('Custom Splash Loader'), findsOneWidget);
      expect(find.text('Main App Screen'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Complete bootstrapAsync; minimumBootstrapTime (~1000ms) must still keep custom appLoader visible.
      gate.complete();
      await tester.pump();
      expect(log, contains('A:bootstrapAsync:end'));
      expect(log, isNot(contains('A:onReady')));
      expect(find.text('Custom Splash Loader'), findsOneWidget);
      expect(find.text('Main App Screen'), findsNothing);

      // After 300ms (still below 1000ms), loader remains visible and onReady has not fired yet.
      await tester.pump(const Duration(milliseconds: 300));
      expect(log, isNot(contains('A:onReady')));
      expect(find.text('Custom Splash Loader'), findsOneWidget);
      expect(find.text('Main App Screen'), findsNothing);

      // After total elapsed time passes minimumBootstrapTime, onReady fires and child renders.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      expect(log, contains('A:onReady'));
      expect(find.text('Custom Splash Loader'), findsNothing);
      expect(find.text('Main App Screen'), findsOneWidget);
    });

    testWidgets('default appLoader displays CircularProgressIndicator while initializing', (tester) async {
      final gate = Completer<void>();

      await tester.pumpWidget(
        Momentum(
          controllers: [],
          initializer: () => gate.future,
          child: const MaterialApp(
            home: Scaffold(body: Text('Loaded Child')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loaded Child'), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loaded Child'), findsOneWidget);
    });
  });
}
