import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../demo_app/services/index.dart';

abstract class _RepoService extends MomentumService {
  String get label;
}

class _AlphaRepoService extends _RepoService {
  @override
  String get label => 'alpha';
}

class _BetaRepoService extends _RepoService {
  @override
  String get label => 'beta';
}

class _OtherService extends MomentumService {
  final String id;
  _OtherService(this.id);
}

class _WrappedCallerService extends MomentumService {
  final String name;
  _WrappedCallerService(this.name);

  _OtherService fetchOther({dynamic alias}) => service<_OtherService>(alias: alias);

  _RepoService fetchRepo({dynamic alias}) => service<_RepoService>(runtimeType: false, alias: alias);
}

class _MyInjectService extends MomentumService {
  final String tag;
  _MyInjectService(this.tag);

  _OtherService fetchOther() => service<_OtherService>();
}

class _ServiceProbeModel extends MomentumModel<_ServiceProbeController> {
  const _ServiceProbeModel(_ServiceProbeController controller) : super(controller);

  @override
  void update() {
    _ServiceProbeModel(controller).updateMomentum();
  }
}

class _ServiceProbeController extends MomentumController<_ServiceProbeModel> {
  @override
  _ServiceProbeModel init() => _ServiceProbeModel(this);
}

void main() {
  test('<MomentumService> test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          InjectService('A', ApiService('A')),
          InjectService('B', DummyService()),
          InjectService('C', ApiService('C')),
        ],
      ),
    );
    await tester.init();

    var api = tester.service<ApiService>(alias: 'A');
    expect(api, isInstanceOf<ApiService>());
    expect(api.id, 'A');

    var dummy = tester.service<DummyService>(alias: 'B');
    expect(dummy, isInstanceOf<DummyService>());

    InjectService<ApiService> injected;
    injected = tester.service<InjectService<ApiService>>();
    expect(injected.value.id, 'A'); // If alias isn't provided, the first occurence gets returned.

    InjectService<ApiService> injectedC;
    injectedC = tester.service<InjectService<ApiService>>(alias: 'C');
    expect(injectedC.value.id, 'C');

    ApiService injectedWithAlias;
    injectedWithAlias = tester.service<ApiService>(alias: 'C');
    expect(injectedWithAlias.id, 'C');
  });

  test('<MomentumService> error test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          InjectService('A', ApiService()),
          InjectService('B', DummyService()),
        ],
      ),
    );
    await tester.init();

    expect(
      () => tester.service<ApiService>(alias: 'B'),
      throwsA(isA<MomentumError>()),
    );

    expect(
      () => tester.service<DummyService>(alias: 'A'),
      throwsA(isA<MomentumError>()),
    );

    expect(
      () => tester.service<InjectService>(),
      throwsA(isA<MomentumError>()),
    );

    expect(
      () => tester.service<InjectService<dynamic>>(),
      throwsA(isA<MomentumError>()),
    );
  });

  group('test services group', () {
    test('test inject service with error', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
          ],
        ),
      );
      await tester.init();

      expect(
        () => tester.service<InjectService>(),
        throwsA(isA<MomentumError>()),
      );

      var tester2 = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
          ],
        ),
      );
      await tester2.init();

      expect(
        () => tester2.service<InjectService<dynamic>>(),
        throwsA(isA<MomentumError>()),
      );
    });

    test('test inject service (targeted type)', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
            DummyService(),
          ],
        ),
      );
      await tester.init();

      var apiService = tester.service<ApiService>();
      var dummyService = tester.service<DummyService>();

      expect(apiService, isInstanceOf<ApiService>());
      expect(dummyService, isInstanceOf<DummyService>());
    });

    test('test inject service error (targeted type)', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', DummyService()),
            DummyService(),
          ],
        ),
      );
      await tester.init();

      var dummyService = tester.service<DummyService>();
      expect(dummyService, isInstanceOf<DummyService>());

      expect(
        () => tester.service<InjectService<ApiService>>(alias: 'srv1'),
        throwsA(isA<MomentumError>()),
      );
    });
  });

  group('InjectService production DI, runtimeType: false & InjectService-named classes', () {
    testWidgets('InjectService-wrapped service can call service<Other>() in a widget tree', (tester) async {
      final wrappedCaller = _WrappedCallerService('caller-1');
      final otherDirect = _OtherService('direct');
      final otherAliased = _OtherService('aliased');
      late BuildContext capturedContext;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [],
          services: [
            InjectService('caller', wrappedCaller),
            otherDirect,
            InjectService('otherAliased', otherAliased),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final resolvedCaller = Momentum.service<_WrappedCallerService>(capturedContext, alias: 'caller');
      expect(resolvedCaller, same(wrappedCaller));

      // Wrapped service resolves both direct and aliased sibling services using its initialized _context.
      expect(resolvedCaller.fetchOther(), same(otherDirect));
      expect(resolvedCaller.fetchOther(alias: 'otherAliased'), same(otherAliased));

      // Reverse lookup from direct service to InjectService-wrapped service.
      expect(otherDirect.service<_WrappedCallerService>(alias: 'caller'), same(wrappedCaller));
    });

    test('InjectService-wrapped service can call service<Other>() with MomentumTester', () async {
      final wrappedCaller = _WrappedCallerService('caller-unit');
      final otherDirect = _OtherService('direct-unit');
      final otherAliased = _OtherService('aliased-unit');

      final tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('caller', wrappedCaller),
            otherDirect,
            InjectService('otherAliased', otherAliased),
          ],
        ),
      );
      await tester.init();

      final resolvedCaller = tester.service<_WrappedCallerService>(alias: 'caller');
      expect(resolvedCaller, same(wrappedCaller));
      expect(resolvedCaller.fetchOther(), same(otherDirect));
      expect(resolvedCaller.fetchOther(alias: 'otherAliased'), same(otherAliased));
    });

    testWidgets('runtimeType: false resolves direct abstract/base services from widgets, controllers & services', (tester) async {
      final alphaRepo = _AlphaRepoService();
      final consumerService = _WrappedCallerService('consumer');
      final probeController = _ServiceProbeController();
      late BuildContext capturedContext;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [probeController],
          services: [alphaRepo, consumerService],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exact runtimeType: true (default) does NOT match abstract superclass.
      expect(
        () => Momentum.service<_RepoService>(capturedContext),
        throwsA(isA<MomentumError>()),
      );
      expect(
        () => probeController.service<_RepoService>(),
        throwsA(isA<MomentumError>()),
      );
      expect(
        () => consumerService.service<_RepoService>(),
        throwsA(isA<MomentumError>()),
      );

      // runtimeType: false matches concrete subclass from widget, controller, and sibling service.
      expect(
        Momentum.service<_RepoService>(capturedContext, runtimeType: false),
        same(alphaRepo),
      );
      expect(
        probeController.service<_RepoService>(runtimeType: false),
        same(alphaRepo),
      );
      expect(
        consumerService.service<_RepoService>(runtimeType: false),
        same(alphaRepo),
      );
    });

    testWidgets('runtimeType: false resolves InjectService-wrapped abstract/base services with and without alias from widgets, controllers & services', (tester) async {
      final alphaRepo = _AlphaRepoService();
      final betaRepo = _BetaRepoService();
      final wrappedConsumer = _WrappedCallerService('wrapped-consumer');
      final probeController = _ServiceProbeController();
      late BuildContext capturedContext;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [probeController],
          services: [
            InjectService('alpha', alphaRepo),
            InjectService('beta', betaRepo),
            InjectService('consumer', wrappedConsumer),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without alias: returns first matching InjectService-wrapped subtype.
      expect(
        Momentum.service<_RepoService>(capturedContext, runtimeType: false),
        same(alphaRepo),
      );
      expect(
        probeController.service<_RepoService>(runtimeType: false),
        same(alphaRepo),
      );
      expect(
        wrappedConsumer.fetchRepo(),
        same(alphaRepo),
      );
      expect(
        Momentum.service<InjectService<_RepoService>>(capturedContext, runtimeType: false).value,
        same(alphaRepo),
      );

      // With alias: selects the exact aliased subtype across widget, controller, and InjectService-wrapped service.
      expect(
        Momentum.service<_RepoService>(capturedContext, runtimeType: false, alias: 'beta'),
        same(betaRepo),
      );
      expect(
        probeController.service<_RepoService>(runtimeType: false, alias: 'beta'),
        same(betaRepo),
      );
      expect(
        wrappedConsumer.fetchRepo(alias: 'beta'),
        same(betaRepo),
      );
      expect(
        Momentum.service<InjectService<_RepoService>>(capturedContext, runtimeType: false, alias: 'beta').value,
        same(betaRepo),
      );
      expect(
        probeController.service<InjectService<_RepoService>>(runtimeType: false, alias: 'alpha').value,
        same(alphaRepo),
      );
      expect(
        wrappedConsumer.service<InjectService<_RepoService>>(runtimeType: false, alias: 'beta').value,
        same(betaRepo),
      );

      // Missing alias or incompatible service type under alias throws MomentumError.
      expect(
        () => Momentum.service<_RepoService>(capturedContext, runtimeType: false, alias: 'missing'),
        throwsA(isA<MomentumError>()),
      );
      expect(
        () => Momentum.service<_RepoService>(capturedContext, runtimeType: false, alias: 'consumer'),
        throwsA(isA<MomentumError>()),
      );
      expect(
        () => probeController.service<_RepoService>(runtimeType: false, alias: 'consumer'),
        throwsA(isA<MomentumError>()),
      );
    });

    test('runtimeType: false with alias & InjectService works in MomentumTester', () async {
      final alphaRepo = _AlphaRepoService();
      final betaRepo = _BetaRepoService();
      final wrappedConsumer = _WrappedCallerService('tester-consumer');
      final probeController = _ServiceProbeController();

      final tester = MomentumTester(
        Momentum(
          controllers: [probeController],
          services: [
            InjectService('alpha', alphaRepo),
            InjectService('beta', betaRepo),
            InjectService('consumer', wrappedConsumer),
          ],
        ),
      );
      await tester.init();

      expect(tester.service<_RepoService>(runtimeType: false), same(alphaRepo));
      expect(tester.service<_RepoService>(runtimeType: false, alias: 'beta'), same(betaRepo));
      expect(probeController.service<_RepoService>(runtimeType: false, alias: 'beta'), same(betaRepo));
      expect(wrappedConsumer.fetchRepo(alias: 'beta'), same(betaRepo));
      expect(
        tester.service<InjectService<_RepoService>>(runtimeType: false, alias: 'beta').value,
        same(betaRepo),
      );
    });

    testWidgets('service class names containing "InjectService" resolve cleanly (direct, wrapped, aliased, runtimeType true & false)', (tester) async {
      // Case 1: Direct registration of a class whose name contains "InjectService".
      final directService = _MyInjectService('direct');
      final directController = _ServiceProbeController();
      final directSibling = _OtherService('sibling');
      late BuildContext directCtx;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [directController],
          services: [directService, directSibling],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                directCtx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(Momentum.service<_MyInjectService>(directCtx), same(directService));
      expect(Momentum.service<_MyInjectService>(directCtx, runtimeType: false), same(directService));
      expect(directController.service<_MyInjectService>(), same(directService));
      expect(directController.service<_MyInjectService>(runtimeType: false), same(directService));
      expect(directSibling.service<_MyInjectService>(), same(directService));
      expect(directSibling.service<_MyInjectService>(runtimeType: false), same(directService));
      expect(directService.fetchOther(), same(directSibling));

      // Case 2: Wrapped inside InjectService with aliases.
      final wrappedOne = _MyInjectService('one');
      final wrappedTwo = _MyInjectService('two');
      final wrappedController = _ServiceProbeController();
      final otherService = _OtherService('other');
      late BuildContext wrappedCtx;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [wrappedController],
          services: [
            InjectService('first', wrappedOne),
            InjectService('second', wrappedTwo),
            otherService,
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                wrappedCtx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without alias (runtimeType: true & false) returns unwrapped _MyInjectService.
      expect(Momentum.service<_MyInjectService>(wrappedCtx), same(wrappedOne));
      expect(Momentum.service<_MyInjectService>(wrappedCtx, runtimeType: false), same(wrappedOne));
      expect(wrappedController.service<_MyInjectService>(), same(wrappedOne));
      expect(wrappedController.service<_MyInjectService>(runtimeType: false), same(wrappedOne));
      expect(otherService.service<_MyInjectService>(), same(wrappedOne));
      expect(otherService.service<_MyInjectService>(runtimeType: false), same(wrappedOne));

      // With alias (runtimeType: true & false) returns exact unwrapped _MyInjectService instance.
      expect(Momentum.service<_MyInjectService>(wrappedCtx, alias: 'second'), same(wrappedTwo));
      expect(Momentum.service<_MyInjectService>(wrappedCtx, runtimeType: false, alias: 'second'), same(wrappedTwo));
      expect(wrappedController.service<_MyInjectService>(alias: 'second'), same(wrappedTwo));
      expect(wrappedController.service<_MyInjectService>(runtimeType: false, alias: 'second'), same(wrappedTwo));
      expect(otherService.service<_MyInjectService>(alias: 'second'), same(wrappedTwo));
      expect(otherService.service<_MyInjectService>(runtimeType: false, alias: 'second'), same(wrappedTwo));

      // Explicitly requesting InjectService<_MyInjectService> still returns the wrapper.
      final wrapper = Momentum.service<InjectService<_MyInjectService>>(wrappedCtx, alias: 'second');
      expect(wrapper, isA<InjectService<_MyInjectService>>());
      expect(wrapper.value, same(wrappedTwo));

      // Wrapped _MyInjectService can also resolve sibling services in widget tree.
      expect(wrappedOne.fetchOther(), same(otherService));
      expect(wrappedTwo.fetchOther(), same(otherService));
    });
  });
}
