import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/widgets/pages/example-basic-list-routed/index.dart';
import '../demo_app/widgets/pages/example-todo/index.dart';
import '../demo_app/widgets/pages/home/index.dart';

void main() {
  group('Test basic routing', () {
    testWidgets('Test goto and pop', (tester) async {
      var momentumRouter = MomentumRouter([
        HomePage(),
        BasicListRoutedPage(),
        TodoExamplePage(),
      ]);
      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [momentumRouter],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();
      homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(find.byKey(homeBackButton));
      await tester.pumpAndSettle();
      expect(momentumRouter.exited, true);
    });
  });

  group('Test persisted routing', () {
    Momentum root(Map<String?, String?> inMemoryStorage) {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [
          MomentumRouter([
            HomePage(withTransition: true),
            BasicListRoutedPage(withTransition: true),
            TodoExamplePage(),
          ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
        persistSave: (context, key, value) async {
          inMemoryStorage[key] = value;
          return true;
        },
        persistGet: (context, key) async {
          return inMemoryStorage[key];
        },
      );
    }

    testWidgets('Test goto and pop (persist and restore)', (tester) async {
      final inMemoryStorage = <String?, String?>{};

      // 1st run: navigate to Todo page
      await tester.pumpWidget(root(inMemoryStorage));
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(todoListMenuKey));
      await tester.pumpAndSettle();
      expect(find.text('TODO List Example'), findsOneWidget);

      // 2nd run: restart with persisted storage and verify active page restored
      await tester.pumpWidget(root(inMemoryStorage));
      await tester.pumpAndSettle();

      expect(find.text('TODO List Example'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
    });
  });

  group('Test routing management (clear and reset)', () {
    testWidgets('Test goto -> pop -> clear and reset', (tester) async {
      final inMemoryStorage = <String, String?>{};
      var momentumRouter = MomentumRouter([
        HomePage(),
        BasicListRoutedPage(),
        TodoExamplePage(),
      ]);
      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [momentumRouter],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
          persistSave: (context, key, value) async {
            inMemoryStorage[key] = value;
            return true;
          },
          persistGet: (context, key) async {
            return inMemoryStorage[key];
          },
        ),
      );
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(clearRouterButton));
      await tester.pumpAndSettle();
      expect(momentumRouter.isRoutesEmpty, true);

      await tester.tap(find.byKey(resetRouterButton));
      await tester.pumpAndSettle();
      homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);
      expect(momentumRouter.isRoutesEmpty, false);
    });
  });

  group('Test misconfigured routing', () {
    Momentum root() {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [
          MomentumRouter([
            HomePage(),
          ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
      );
    }

    testWidgets('Test goto and pop', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
      expect(find.byKey(basicListMenuKey), findsOneWidget);
    });
  });

  group('Test persisted routing edge cases (Dart 3 & malformed JSON)', () {
    testWidgets('Restores persisted route from typed Future<String?> persistGet', (tester) async {
      Future<String?> persistGet(BuildContext? context, String key) async {
        return '[0, 2]';
      }

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [
            MomentumRouter([
              HomePage(),
              BasicListRoutedPage(),
              TodoExamplePage(),
            ]),
          ],
          persistSave: (context, key, value) async => true,
          persistGet: persistGet,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('TODO List Example'), findsOneWidget);
    });

    testWidgets('Falls back to initial page when persisted JSON is malformed', (tester) async {
      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [
            MomentumRouter([
              HomePage(),
              BasicListRoutedPage(),
              TodoExamplePage(),
            ]),
          ],
          persistSave: (context, key, value) async => true,
          persistGet: (context, key) async => '{malformed json',
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
    });

    testWidgets('Falls back to initial page when persisted JSON is non-list or invalid element types', (tester) async {
      for (final rawJson in ['{"not": "a list"}', '["not-an-int"]', 'null', null]) {
        await tester.pumpWidget(
          Momentum(
            key: UniqueKey(),
            controllers: [BasicListExampleController(), TodoExampleController()],
            services: [
              MomentumRouter([
                HomePage(),
                BasicListRoutedPage(),
                TodoExamplePage(),
              ]),
            ],
            persistSave: (context, key, value) async => true,
            persistGet: (context, key) async => rawJson,
            child: MaterialApp(
              home: Builder(
                builder: (context) => MomentumRouter.getActivePage(context),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Momentum Flutter Demo'), findsOneWidget);
      }
    });

    testWidgets('Falls back to initial page when typed Future<String?> persistGet returns null or throws', (tester) async {
      Future<String?> nullPersistGet(BuildContext? context, String key) async => null;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [
            MomentumRouter([
              HomePage(),
              BasicListRoutedPage(),
              TodoExamplePage(),
            ]),
          ],
          persistSave: (context, key, value) async => true,
          persistGet: nullPersistGet,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);

      Future<String?> throwingPersistGet(BuildContext? context, String key) async {
        throw StateError('storage unavailable');
      }

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [
            MomentumRouter([
              HomePage(),
              BasicListRoutedPage(),
              TodoExamplePage(),
            ]),
          ],
          persistSave: (context, key, value) async => true,
          persistGet: throwingPersistGet,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
    });

    testWidgets('Handles out-of-range persisted indices safely (all invalid and mixed valid/invalid)', (tester) async {
      // All indices out of range -> falls back to initial page (index 0).
      for (final rawJson in ['[-1]', '[3]', '[-5, 99, 100]']) {
        Future<String?> persistGet(BuildContext? context, String key) async => rawJson;
        await tester.pumpWidget(
          Momentum(
            key: UniqueKey(),
            controllers: [BasicListExampleController(), TodoExampleController()],
            services: [
              MomentumRouter([
                HomePage(),
                BasicListRoutedPage(),
                TodoExamplePage(),
              ]),
            ],
            persistSave: (context, key, value) async => true,
            persistGet: persistGet,
            child: MaterialApp(
              home: Builder(
                builder: (context) => MomentumRouter.getActivePage(context),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'rawJson=$rawJson');
        expect(find.text('Momentum Flutter Demo'), findsOneWidget, reason: 'rawJson=$rawJson');
      }

      // Mixed valid and out-of-range indices -> strips invalid indices, keeping [1, 2].
      final router = MomentumRouter([
        HomePage(),
        BasicListRoutedPage(),
        TodoExamplePage(),
      ]);
      Future<String?> mixedPersistGet(BuildContext? context, String key) async => '[-1, 1, 99, 2, 50]';

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [router],
          persistSave: (context, key, value) async => true,
          persistGet: mixedPersistGet,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Last valid index is 2 -> TodoExamplePage.
      expect(find.text('TODO List Example'), findsOneWidget);

      // Popping moves to the remaining valid index 1 -> BasicListRoutedPage.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Basic List (routed)'), findsOneWidget);

      // Popping again empties history and exits rather than accessing invalid index -1.
      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();
      expect(router.exited, isTrue);
    });

    test('MomentumRouter.getActive throws MomentumError when pages list is empty', () {
      final router = MomentumRouter([]);
      expect(() => router.getActive(), throwsA(isA<MomentumError>()));
    });
  });

  group('Test enablePersistence: false', () {
    testWidgets('enablePersistence: false skips persistSave on goto, pop, clearHistory, reset and does not restore on restart', (tester) async {
      final inMemoryStorage = <String, String?>{};
      final saveCalls = <String?>[];

      Momentum buildApp(MomentumRouter router) {
        return Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController(), TodoExampleController()],
          services: [router],
          persistSave: (context, key, value) async {
            saveCalls.add(value);
            inMemoryStorage[key] = value;
            return true;
          },
          persistGet: (context, key) async => inMemoryStorage[key],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        );
      }

      final router1 = MomentumRouter(
        [
          HomePage(),
          BasicListRoutedPage(),
          TodoExamplePage(),
        ],
        enablePersistence: false,
      );

      await tester.pumpWidget(buildApp(router1));
      await tester.pumpAndSettle();
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);

      // goto -> BasicListRoutedPage
      await tester.tap(find.byKey(basicListMenuKey));
      await tester.pumpAndSettle();
      expect(find.text('Basic List (routed)'), findsOneWidget);

      // pop -> HomePage
      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);

      // goto -> BasicListRoutedPage -> clearHistory -> reset
      await tester.tap(find.byKey(basicListMenuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(clearRouterButton));
      await tester.pumpAndSettle();
      expect(router1.isRoutesEmpty, isTrue);

      await tester.tap(find.byKey(resetRouterButton));
      await tester.pumpAndSettle();
      expect(router1.isRoutesEmpty, isFalse);

      // goto -> TodoExamplePage before restarting
      await tester.tap(find.byKey(todoListMenuKey));
      await tester.pumpAndSettle();
      expect(find.text('TODO List Example'), findsOneWidget);

      // persistSave must never have been invoked for router history.
      expect(saveCalls, isEmpty);
      expect(inMemoryStorage.containsKey('MOMENTUM_ROUTER_HISTORY'), isFalse);

      // Restart app with fresh MomentumRouter(enablePersistence: false) and same storage:
      // must start at initial page (HomePage), not TodoExamplePage.
      final router2 = MomentumRouter(
        [
          HomePage(),
          BasicListRoutedPage(),
          TodoExamplePage(),
        ],
        enablePersistence: false,
      );
      await tester.pumpWidget(buildApp(router2));
      await tester.pumpAndSettle();
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
      expect(saveCalls, isEmpty);
    });
  });

  group('Test RouterPage onWillPop behavior', () {
    testWidgets('RouterPage default onWillPop calls MomentumRouter.pop and exits on root page', (tester) async {
      late BuildContext pageContext;
      final router = MomentumRouter([
        _RouterPageScreenA(onBuild: (ctx) => pageContext = ctx),
        _RouterPageScreenB(onBuild: (ctx) => pageContext = ctx),
      ]);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [],
          services: [router],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ScreenA'), findsOneWidget);

      MomentumRouter.goto(pageContext, _RouterPageScreenB);
      await tester.pumpAndSettle();
      expect(find.text('ScreenB'), findsOneWidget);

      // System back invokes default onWillPop -> MomentumRouter.pop -> returns to ScreenA.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('ScreenA'), findsOneWidget);
      expect(router.exited, isFalse);

      // System back on the root page invokes MomentumRouter.pop -> empties history and sets exited.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(router.exited, isTrue);
    });

    testWidgets('RouterPage custom onWillPop returning false blocks both MomentumRouter.pop and Navigator.pop', (tester) async {
      late BuildContext pageContext;
      var rootCustomPopCalls = 0;
      var overlayCustomPopCalls = 0;

      final router = MomentumRouter([
        _RouterPageScreenA(onBuild: (ctx) => pageContext = ctx),
        _RouterPageCustomPopScreen(
          label: 'CustomFalseScreen',
          onBuild: (ctx) => pageContext = ctx,
          onWillPop: () async {
            rootCustomPopCalls++;
            return false;
          },
        ),
      ]);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [],
          services: [router],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate via MomentumRouter to custom onWillPop -> false screen.
      MomentumRouter.goto(pageContext, _RouterPageCustomPopScreen);
      await tester.pumpAndSettle();
      expect(find.text('CustomFalseScreen'), findsOneWidget);

      // System back must invoke custom onWillPop and stay on CustomFalseScreen (not call MomentumRouter.pop).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rootCustomPopCalls, 1);
      expect(find.text('CustomFalseScreen'), findsOneWidget);
      expect(find.text('ScreenA'), findsNothing);

      // Push a regular Navigator route wrapped in RouterPage with onWillPop -> false (navigator.canPop() == true).
      Navigator.of(pageContext).push(
        MaterialPageRoute(
          builder: (_) => RouterPage(
            onWillPop: () async {
              overlayCustomPopCalls++;
              return false;
            },
            child: const Scaffold(body: Text('OverlayBlocked')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('OverlayBlocked'), findsOneWidget);

      // System back must invoke onWillPop -> false and keep the pushed overlay route on screen.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(overlayCustomPopCalls, 1);
      expect(find.text('OverlayBlocked'), findsOneWidget);
    });

    testWidgets('RouterPage custom onWillPop returning true pops when navigator canPop and safely no-ops at root', (tester) async {
      late BuildContext pageContext;
      var overlayPopCalls = 0;
      var rootPopCalls = 0;

      final router = MomentumRouter([
        _RouterPageCustomPopScreen(
          label: 'RootTrueScreen',
          onBuild: (ctx) => pageContext = ctx,
          onWillPop: () async {
            rootPopCalls++;
            return true;
          },
        ),
      ]);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [],
          services: [router],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('RootTrueScreen'), findsOneWidget);

      // Push an overlay route wrapped in RouterPage with custom onWillPop -> true.
      Navigator.of(pageContext).push(
        MaterialPageRoute(
          builder: (_) => RouterPage(
            onWillPop: () async {
              overlayPopCalls++;
              return true;
            },
            child: const Scaffold(body: Text('OverlayPoppable')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('OverlayPoppable'), findsOneWidget);

      // System back invokes onWillPop -> true and pops the Navigator route cleanly.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(overlayPopCalls, 1);
      expect(find.text('OverlayPoppable'), findsNothing);
      expect(find.text('RootTrueScreen'), findsOneWidget);

      // System back on root page where navigator.canPop() is false invokes onWillPop -> true safely without throwing.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rootPopCalls, 1);
      expect(tester.takeException(), isNull);
      expect(find.text('RootTrueScreen'), findsOneWidget);
      expect(router.exited, isFalse);
    });
  });

  group('Test MomentumRouter.pop(result: param)', () {
    testWidgets('pop(result: param) delivers RouterParam to RouterMixin.onRouteChanged and getParam', (tester) async {
      late BuildContext activeContext;
      final paramController = _RouteParamProbeController();
      final router = MomentumRouter([
        _RouterPageScreenA(onBuild: (ctx) => activeContext = ctx),
        _RouterPageScreenB(onBuild: (ctx) => activeContext = ctx),
      ]);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [paramController],
          services: [router],
          child: MaterialApp(
            home: Builder(
              builder: (context) => MomentumRouter.getActivePage(context),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ScreenA'), findsOneWidget);

      // Navigate to ScreenB with a Goto param.
      final gotoParam = _GotoRouteParam('hello-b');
      MomentumRouter.goto(activeContext, _RouterPageScreenB, params: gotoParam);
      await tester.pumpAndSettle();
      expect(find.text('ScreenB'), findsOneWidget);
      expect(paramController.receivedParams, [gotoParam]);
      expect(MomentumRouter.getParam<_GotoRouteParam>(activeContext), same(gotoParam));
      expect(paramController.getParam<_GotoRouteParam>(), same(gotoParam));

      // Pop back to ScreenA with a result RouterParam.
      final popResult = _PopResultRouteParam('returned-from-b');
      MomentumRouter.pop(activeContext, result: popResult);
      await tester.pumpAndSettle();
      expect(find.text('ScreenA'), findsOneWidget);
      expect(paramController.receivedParams, [gotoParam, popResult]);
      expect(MomentumRouter.getParam<_PopResultRouteParam>(activeContext), same(popResult));
      expect(paramController.getParam<_PopResultRouteParam>(), same(popResult));
      // Previous param type must no longer match.
      expect(MomentumRouter.getParam<_GotoRouteParam>(activeContext), isNull);
      expect(paramController.getParam<_GotoRouteParam>(), isNull);

      // Goto ScreenB and pop without result -> clears current param to null.
      MomentumRouter.goto(activeContext, _RouterPageScreenB, params: gotoParam);
      await tester.pumpAndSettle();
      MomentumRouter.pop(activeContext);
      await tester.pumpAndSettle();
      expect(find.text('ScreenA'), findsOneWidget);
      expect(paramController.receivedParams.last, isNull);
      expect(MomentumRouter.getParam<_PopResultRouteParam>(activeContext), isNull);
      expect(MomentumRouter.getParam<_GotoRouteParam>(activeContext), isNull);
    });
  });
}

class _GotoRouteParam extends RouterParam {
  final String value;
  _GotoRouteParam(this.value);
}

class _PopResultRouteParam extends RouterParam {
  final String result;
  _PopResultRouteParam(this.result);
}

class _RouteParamProbeModel extends MomentumModel<_RouteParamProbeController> {
  const _RouteParamProbeModel(_RouteParamProbeController controller) : super(controller);

  @override
  void update() {
    _RouteParamProbeModel(controller).updateMomentum();
  }
}

class _RouteParamProbeController extends MomentumController<_RouteParamProbeModel> with RouterMixin {
  final List<RouterParam?> receivedParams = [];

  @override
  _RouteParamProbeModel init() => _RouteParamProbeModel(this);

  @override
  void onRouteChanged(RouterParam? param) {
    receivedParams.add(param);
  }
}

class _RouterPageScreenA extends StatelessWidget {
  final void Function(BuildContext context) onBuild;
  const _RouterPageScreenA({required this.onBuild});

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return const RouterPage(
      child: Scaffold(body: Text('ScreenA')),
    );
  }
}

class _RouterPageScreenB extends StatelessWidget {
  final void Function(BuildContext context) onBuild;
  const _RouterPageScreenB({required this.onBuild});

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return const RouterPage(
      child: Scaffold(body: Text('ScreenB')),
    );
  }
}

class _RouterPageCustomPopScreen extends StatelessWidget {
  final String label;
  final void Function(BuildContext context) onBuild;
  final Future<bool> Function() onWillPop;

  const _RouterPageCustomPopScreen({
    required this.label,
    required this.onBuild,
    required this.onWillPop,
  });

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return RouterPage(
      onWillPop: onWillPop,
      child: Scaffold(body: Text(label)),
    );
  }
}
