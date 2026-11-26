import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/basic-list-example/index.dart';
import '../../../demo_app/widgets/pages/example-basic-list-routed/index.dart';
import '../../utils.dart';

void main() {
  test('<BasicListExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          BasicListExampleController()..config(maxTimeTravelSteps: 10),
        ],
      ),
    );
    await tester.init();

    var controller = tester.controller<BasicListExampleController>()!;
    isControllerValid<BasicListExampleController>(controller);
    isModelValid<BasicListExampleModel>(controller.model);

    expect(controller.model.list, []);

    controller.addNewRandom();
    expect(controller.model.list!.length, 1);
    controller.addNewRandom();
    expect(controller.model.list!.length, 2);
    controller.addNewRandom();
    controller.addNewRandom();
    controller.addNewRandom();
    controller.addNewRandom();
    expect(controller.model.list!.length, 6);

    // undo/redo tests
    controller.undo();
    expect(controller.model.list!.length, 5);
    controller.undo();
    expect(controller.model.list!.length, 4);
    controller.redo();
    expect(controller.model.list!.length, 5);
    controller.redo();
    expect(controller.model.list!.length, 6);

    // remove item test
    var secondItem = controller.model.list![1];
    expect(controller.model.list!.any((x) => x == secondItem), true);
    controller.remove(1);
    expect(controller.model.list!.any((x) => x == secondItem), false);
    expect(controller.model.list!.length, 5);

    controller.model.update(list: null);
    expect(controller.model.list!.length, 5);
  });

  test('<BasicListExampleController> router param test', () async {
    var basicCtrl = BasicListExampleController();
    var tester = MomentumTester(
      Momentum(
        controllers: [
          basicCtrl,
        ],
        services: [MomentumRouter([])],
      ),
    );
    await tester.init();

    tester.mockRouterParam(BasicListRouteParam(['Apple', 'Orange']));

    expect(basicCtrl.latestList, 'Apple,Orange');
  });

  testWidgets('<BasicListExampleController> non lazy controller', (tester) async {
    var basicCtrl = BasicListExampleController()..config(lazy: false);
    expect(basicCtrl.value, 0);
    expect(basicCtrl.value2, 0);

    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(),
        ),
        controllers: [basicCtrl],
      ),
    );
    await tester.pumpAndSettle();

    expect(basicCtrl.value, 99);
    expect(basicCtrl.value2, 88);
  });

  group('Time-travel edge cases', () {
    test('undo back to initial sets prevModel to null and extra backward is a no-op', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [
            BasicListExampleController()..config(maxTimeTravelSteps: 10),
          ],
        ),
      );
      await tester.init();

      var controller = tester.controller<BasicListExampleController>()!;
      expect(controller.model.list, const []);
      expect(controller.prevModel, isNull);
      expect(controller.nextModel, isNull);

      controller.model.update(list: ['A']);
      controller.model.update(list: ['A', 'B']);
      expect(controller.model.list, ['A', 'B']);
      expect(controller.prevModel?.list, ['A']);
      expect(controller.nextModel, isNull);

      controller.backward();
      expect(controller.model.list, ['A']);
      expect(controller.prevModel?.list, const []);
      expect(controller.nextModel?.list, ['A', 'B']);

      controller.backward();
      expect(controller.model.list, const []);
      expect(controller.prevModel, isNull);
      expect(controller.nextModel?.list, ['A']);

      // Extra backward at initial state must be a no-op.
      controller.backward();
      expect(controller.model.list, const []);
      expect(controller.prevModel, isNull);
      expect(controller.nextModel?.list, ['A']);
    });

    test('branching after undo discards redo history without resurrection', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [
            BasicListExampleController()..config(maxTimeTravelSteps: 10),
          ],
        ),
      );
      await tester.init();

      var controller = tester.controller<BasicListExampleController>()!;
      controller.model.update(list: ['A']);
      controller.model.update(list: ['A', 'B']);
      controller.model.update(list: ['A', 'B', 'C']);

      controller.backward();
      controller.backward();
      expect(controller.model.list, ['A']);
      expect(controller.nextModel?.list, ['A', 'B']);

      // Branch with a new state.
      controller.model.update(list: ['A', 'X']);
      expect(controller.model.list, ['A', 'X']);
      expect(controller.prevModel?.list, ['A']);
      expect(controller.nextModel, isNull);

      // Redo must not resurrect the discarded 'B'/'C' states.
      controller.forward();
      expect(controller.model.list, ['A', 'X']);
      expect(controller.nextModel, isNull);
    });

    test('maxTimeTravelSteps clamping (<1 and >250) and capacity eviction', () async {
      // < 1 clamps to 1 (no undo history beyond current state).
      for (final invalidSteps in [0, -5]) {
        var tester = MomentumTester(
          Momentum(
            controllers: [
              BasicListExampleController()..config(maxTimeTravelSteps: invalidSteps),
            ],
          ),
        );
        await tester.init();

        var controller = tester.controller<BasicListExampleController>()!;
        controller.model.update(list: ['A']);
        expect(controller.model.list, ['A']);
        expect(controller.prevModel, isNull);
        controller.backward();
        expect(controller.model.list, ['A']);
      }

      // Capacity eviction with maxTimeTravelSteps: 3.
      var evictionTester = MomentumTester(
        Momentum(
          controllers: [
            BasicListExampleController()..config(maxTimeTravelSteps: 3),
          ],
        ),
      );
      await evictionTester.init();

      var evictionCtrl = evictionTester.controller<BasicListExampleController>()!;
      evictionCtrl.model.update(list: ['1']);
      evictionCtrl.model.update(list: ['1', '2']);
      evictionCtrl.model.update(list: ['1', '2', '3']);
      evictionCtrl.model.update(list: ['1', '2', '3', '4']);

      evictionCtrl.backward();
      expect(evictionCtrl.model.list, ['1', '2', '3']);
      evictionCtrl.backward();
      expect(evictionCtrl.model.list, ['1', '2']);
      expect(evictionCtrl.prevModel, isNull);
      // Older states ([], ['1']) were evicted.
      evictionCtrl.backward();
      expect(evictionCtrl.model.list, ['1', '2']);

      // > 250 clamps to 250 snapshots (max 249 backward steps).
      var clampHighTester = MomentumTester(
        Momentum(
          controllers: [
            BasicListExampleController()..config(maxTimeTravelSteps: 500),
          ],
        ),
      );
      await clampHighTester.init();

      var highCtrl = clampHighTester.controller<BasicListExampleController>()!;
      for (var i = 1; i <= 260; i++) {
        highCtrl.model.update(list: ['$i']);
      }
      expect(highCtrl.model.list, ['260']);

      var undoCount = 0;
      while (highCtrl.prevModel != null) {
        highCtrl.backward();
        undoCount++;
      }
      expect(undoCount, 249);
      expect(highCtrl.model.list, ['11']);
      expect(highCtrl.prevModel, isNull);
    });

    testWidgets('Equatable equal-model updates are no-op skips', (tester) async {
      var controller = _EquatableCounterController()..config(maxTimeTravelSteps: 5);
      var buildCount = 0;

      await tester.pumpWidget(
        Momentum(
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: MomentumBuilder(
                controllers: [_EquatableCounterController],
                builder: (context, snapshot) {
                  buildCount++;
                  var model = snapshot<_EquatableCounterModel>();
                  return Text('count:${model.count}');
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(controller.prevModel, isNull);

      // Equal-model update must be skipped (no rebuild, no history entry).
      controller.model.update(count: 0);
      await tester.pumpAndSettle();
      expect(buildCount, 1);
      expect(controller.prevModel, isNull);

      // Distinct value updates model, notifies builder, and records history.
      controller.model.update(count: 1);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(controller.model.count, 1);
      expect(controller.prevModel?.count, 0);

      // Updating with same value 1 again is also a no-op.
      controller.model.update(count: 1);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(controller.prevModel?.count, 0);
    });
  });
}

class _EquatableCounterModel extends MomentumModel<_EquatableCounterController> {
  const _EquatableCounterModel(
    _EquatableCounterController controller, {
    required this.count,
  }) : super(controller);

  final int count;

  @override
  void update({int? count}) {
    _EquatableCounterModel(
      controller,
      count: count ?? this.count,
    ).updateMomentum();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EquatableCounterModel &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

class _EquatableCounterController extends MomentumController<_EquatableCounterModel> {
  @override
  _EquatableCounterModel init() => _EquatableCounterModel(this, count: 0);
}
