import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../demo_app/components/basic-list-example/index.dart';
import '../../demo_app/components/todo-example/index.dart';

void main() {
  testWidgets('test multiple controllers using one model in MomentumBuilder (with error)', (tester) async {
    var basicCtrl = BasicListExampleController();
    var basicCtrlExt = BasicListExtendedController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [
                BasicListExampleController,
                BasicListExtendedController,
              ],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>();
                return Text(basicModel.list!.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl, basicCtrlExt],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test multiple controllers using one model in MomentumBuilder', (tester) async {
    var basicCtrl = BasicListExampleController();
    var basicCtrlExt = BasicListExtendedController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [
                BasicListExampleController,
                BasicListExtendedController,
              ],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>(BasicListExampleController);
                return Text(basicModel.list!.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl, basicCtrlExt],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), null);

    var text = find.byType(Text);
    expect(text, findsOneWidget);
  });

  testWidgets('test missing controller in MomentumBuilder', (tester) async {
    var basicCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>();
                return Text(basicModel.list!.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test missing controller in MomentumBuilder from `dontRebuildIf`', (tester) async {
    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [TodoExampleController],
              dontRebuildIf: (controller, _) {
                expect(
                  () => controller<BasicListExampleController>(),
                  throwsA(isA<MomentumError>()),
                );
                return false;
              },
              builder: (context, snapshot) {
                return Text('text');
              },
            ),
          ),
        ),
        controllers: [todoCtrl],
      ),
    );
    await tester.pumpAndSettle();

    todoCtrl.addTodo('item 1');
    await tester.pumpAndSettle();
  });

  group('Widget lifecycle, rebuild safety & dontRebuildIf', () {
    testWidgets('parent rebuild does not re-run initializer, bootstrap, or duplicate onRouteChanged', (tester) async {
      var initializerCount = 0;
      var ctrl = _LifecycleController()..config(lazy: false);
      var router = MomentumRouter([const _LifecyclePageA(), const _LifecyclePageB()]);
      late StateSetter rebuildParent;
      late BuildContext navContext;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            return Momentum(
              controllers: [ctrl],
              services: [router],
              initializer: () async {
                initializerCount++;
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

      expect(initializerCount, 1);
      expect(ctrl.bootstrapCount, 1);
      expect(ctrl.bootstrapAsyncCount, 1);
      expect(ctrl.routeChangeCount, 0);

      // Trigger multiple parent rebuilds.
      rebuildParent(() {});
      await tester.pumpAndSettle();
      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(initializerCount, 1);
      expect(ctrl.bootstrapCount, 1);
      expect(ctrl.bootstrapAsyncCount, 1);
      expect(ctrl.routeChangeCount, 0);

      // Navigating once should trigger onRouteChanged exactly once.
      MomentumRouter.goto(navContext, _LifecyclePageB);
      await tester.pumpAndSettle();
      expect(ctrl.routeChangeCount, 1);
      expect(find.text('LifecyclePageB'), findsOneWidget);
    });

    testWidgets('dontRebuildIf controls MomentumBuilder build counts', (tester) async {
      var ctrl = _LifecycleController();
      var buildCount = 0;

      await tester.pumpWidget(
        Momentum(
          controllers: [ctrl],
          child: MaterialApp(
            home: Scaffold(
              body: MomentumBuilder(
                controllers: [_LifecycleController],
                dontRebuildIf: (controller, isTimeTravel) {
                  var c = controller<_LifecycleController>();
                  // Skip rebuilds when count is even.
                  return c.model.count.isEven;
                },
                builder: (context, snapshot) {
                  buildCount++;
                  var model = snapshot<_LifecycleModel>();
                  return Text('count:${model.count}');
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(find.text('count:0'), findsOneWidget);

      // Odd -> rebuilds (buildCount: 2).
      ctrl.model.update(count: 1);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(find.text('count:1'), findsOneWidget);

      // Even -> skipped by dontRebuildIf (buildCount stays 2).
      ctrl.model.update(count: 2);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(find.text('count:1'), findsOneWidget);

      // Odd -> rebuilds (buildCount: 3).
      ctrl.model.update(count: 3);
      await tester.pumpAndSettle();
      expect(buildCount, 3);
      expect(find.text('count:3'), findsOneWidget);
    });

    testWidgets('listener cleanup on dispose prevents rebuilds or errors after unmount', (tester) async {
      var ctrl = _LifecycleController();
      var buildCount = 0;
      var showBuilder = true;
      late StateSetter setHostState;

      await tester.pumpWidget(
        Momentum(
          controllers: [ctrl],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  setHostState = setState;
                  if (!showBuilder) {
                    return const Text('disposed');
                  }
                  return MomentumBuilder(
                    controllers: [_LifecycleController],
                    builder: (context, snapshot) {
                      buildCount++;
                      var model = snapshot<_LifecycleModel>();
                      return Text('count:${model.count}');
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      ctrl.model.update(count: 1);
      await tester.pumpAndSettle();
      expect(buildCount, 2);

      // Dispose MomentumBuilder.
      setHostState(() => showBuilder = false);
      await tester.pumpAndSettle();
      expect(find.text('disposed'), findsOneWidget);

      // Subsequent updates must not invoke disposed listener or throw.
      ctrl.model.update(count: 2);
      ctrl.model.update(count: 3);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GlobalKey deactivate/activate reparenting keeps MomentumBuilder active', (tester) async {
      var ctrl = _LifecycleController();
      var builderKey = GlobalKey();
      var inFirstSlot = true;
      var buildCount = 0;
      late StateSetter setHostState;

      Widget buildTrackedBuilder() {
        return MomentumBuilder(
          key: builderKey,
          controllers: [_LifecycleController],
          builder: (context, snapshot) {
            buildCount++;
            var model = snapshot<_LifecycleModel>();
            return Text('reparented:${model.count}');
          },
        );
      }

      await tester.pumpWidget(
        Momentum(
          controllers: [ctrl],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  setHostState = setState;
                  return Column(
                    children: [
                      if (inFirstSlot)
                        Container(key: const Key('slotA'), child: buildTrackedBuilder())
                      else
                        const SizedBox.shrink(),
                      if (!inFirstSlot)
                        Container(key: const Key('slotB'), child: buildTrackedBuilder())
                      else
                        const SizedBox.shrink(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('slotA')), findsOneWidget);
      expect(find.text('reparented:0'), findsOneWidget);

      // Reparent MomentumBuilder from slotA to slotB (triggers deactivate + activate).
      setHostState(() => inFirstSlot = false);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('slotB')), findsOneWidget);
      expect(find.text('reparented:0'), findsOneWidget);

      var buildsAfterReparent = buildCount;
      // Controller update must still notify the reparented MomentumBuilder.
      ctrl.model.update(count: 7);
      await tester.pumpAndSettle();
      expect(buildCount, buildsAfterReparent + 1);
      expect(find.text('reparented:7'), findsOneWidget);
    });

    testWidgets('owner header formatting in MomentumBuilder errors', (tester) async {
      // Without owner:
      await tester.pumpWidget(
        Momentum(
          controllers: [BasicListExampleController()],
          child: MaterialApp(
            home: Scaffold(
              body: MomentumBuilder(
                controllers: const [],
                builder: (context, snapshot) {
                  snapshot<BasicListExampleModel>();
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var errorWithoutOwner = tester.takeException();
      expect(errorWithoutOwner, isA<MomentumError>());
      expect(errorWithoutOwner.toString(), contains('[Momentum > MomentumBuilder]:'));

      // With owner:
      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [BasicListExampleController()],
          child: const MaterialApp(
            home: Scaffold(
              body: _OwnerWidget(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var errorWithOwner = tester.takeException();
      expect(errorWithOwner, isA<MomentumError>());
      expect(
        errorWithOwner.toString(),
        contains('[Momentum > _OwnerWidget > MomentumBuilder]:'),
      );
    });

    testWidgets('changing widget.controllers detaches old listeners and attaches new ones', (tester) async {
      var basicCtrl = BasicListExampleController();
      var todoCtrl = TodoExampleController();
      var activeControllers = <Type>[BasicListExampleController];
      var buildCount = 0;
      late StateSetter setHostState;

      await tester.pumpWidget(
        Momentum(
          controllers: [basicCtrl, todoCtrl],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  setHostState = setState;
                  return MomentumBuilder(
                    controllers: activeControllers,
                    builder: (context, snapshot) {
                      buildCount++;
                      if (activeControllers.contains(BasicListExampleController)) {
                        var model = snapshot<BasicListExampleModel>();
                        return Text('basic:${model.list!.length}');
                      } else {
                        var model = snapshot<TodoExampleModel>();
                        return Text('todo:${model.todoMap!.length}');
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(find.text('basic:0'), findsOneWidget);

      // Updating basicCtrl rebuilds; updating todoCtrl does not.
      basicCtrl.add('A');
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(find.text('basic:1'), findsOneWidget);

      todoCtrl.addTodo('T1');
      await tester.pumpAndSettle();
      expect(buildCount, 2);

      // Switch widget.controllers to TodoExampleController.
      setHostState(() => activeControllers = <Type>[TodoExampleController]);
      await tester.pumpAndSettle();
      expect(buildCount, 3);
      expect(find.text('todo:1'), findsOneWidget);

      // Updating old basicCtrl must NOT rebuild anymore.
      basicCtrl.add('B');
      await tester.pumpAndSettle();
      expect(buildCount, 3);

      // Updating new todoCtrl MUST rebuild.
      todoCtrl.addTodo('T2');
      await tester.pumpAndSettle();
      expect(buildCount, 4);
      expect(find.text('todo:2'), findsOneWidget);
    });
  });
}

class _LifecycleModel extends MomentumModel<_LifecycleController> {
  const _LifecycleModel(_LifecycleController controller, {required this.count}) : super(controller);

  final int count;

  @override
  void update({int? count}) {
    _LifecycleModel(controller, count: count ?? this.count).updateMomentum();
  }
}

class _LifecycleController extends MomentumController<_LifecycleModel> with RouterMixin {
  int bootstrapCount = 0;
  int bootstrapAsyncCount = 0;
  int routeChangeCount = 0;

  @override
  _LifecycleModel init() => _LifecycleModel(this, count: 0);

  @override
  void bootstrap() {
    bootstrapCount++;
  }

  @override
  Future<void> bootstrapAsync() async {
    bootstrapAsyncCount++;
  }

  @override
  void onRouteChanged(RouterParam? param) {
    routeChangeCount++;
  }
}

class _LifecyclePageA extends StatelessWidget {
  const _LifecyclePageA();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('LifecyclePageA'));
}

class _LifecyclePageB extends StatelessWidget {
  const _LifecyclePageB();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('LifecyclePageB'));
}

class _OwnerWidget extends StatelessWidget {
  const _OwnerWidget();

  @override
  Widget build(BuildContext context) {
    return MomentumBuilder(
      owner: this,
      controllers: const [],
      builder: (context, snapshot) {
        snapshot<BasicListExampleModel>();
        return const SizedBox.shrink();
      },
    );
  }
}
