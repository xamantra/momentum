import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/widgets/pages/example-basic-list/index.dart';

void main() {
  group('event system', () {
    Widget _root(BasicListExampleController basicListCtrl) {
      return Momentum(
        child: MaterialApp(
          home: BasicListExamplePage(),
        ),
        enableLogging: true,
        controllers: [basicListCtrl],
      );
    }

    testWidgets('test controller->widget event system', (tester) async {
      var basicListCtrl = BasicListExampleController()..config(maxTimeTravelSteps: 10);
      await tester.pumpWidget(_root(basicListCtrl));
      await tester.pumpAndSettle();

      basicListCtrl.add('item 1');
      basicListCtrl.add('item 2');
      basicListCtrl.add('item 3');
      expect(basicListCtrl.model.list!.length, 3);

      expect(basicListCtrl.model.list!.first, 'item 1');
      expect(basicListCtrl.model.list!.last, 'item 3');
      basicListCtrl.sendEvent(BasicListEvent.reverseList);
      await tester.pumpAndSettle();
      expect(basicListCtrl.model.list!.first, 'item 3');
      expect(basicListCtrl.model.list!.last, 'item 1');

      basicListCtrl.sendEvent(BasicListEvent.clearList);
      await tester.pumpAndSettle();
      expect(basicListCtrl.model.list!.length, 0);
    });

    testWidgets('resetAll(context)->widget event system', (tester) async {
      var basicListCtrl = BasicListExampleController()..config(maxTimeTravelSteps: 10);
      await tester.pumpWidget(_root(basicListCtrl));
      await tester.pumpAndSettle();

      basicListCtrl.add('item 1');
      basicListCtrl.add('item 2');
      basicListCtrl.add('item 3');
      expect(basicListCtrl.model.list!.length, 3);
      expect(basicListCtrl.model.list!.first, 'item 1');
      expect(basicListCtrl.model.list!.last, 'item 3');

      basicListCtrl.sendEvent(BasicListEvent.resetAll);
      await tester.pumpAndSettle();
      expect(basicListCtrl.model.list!.length, 0);
      expect(basicListCtrl.prevModel!.list!.length, 3);

      basicListCtrl.add('item 1');
      basicListCtrl.add('item 2');
      basicListCtrl.add('item 3');
      expect(basicListCtrl.model.list!.length, 3);
      expect(basicListCtrl.model.list!.first, 'item 1');
      expect(basicListCtrl.model.list!.last, 'item 3');

      basicListCtrl.sendEvent(BasicListEvent.resetAllClearHistory);
      await tester.pumpAndSettle();
      expect(basicListCtrl.model.list!.length, 0);
      expect(basicListCtrl.prevModel, null);
      expect(basicListCtrl.nextModel, null);
    });
  });

  group('restart system', () {
    testWidgets('resetAll(context)-> onResetAll Callback', (tester) async {
      var basicCtrl = BasicListExampleController();
      TodoExampleController? todoCtrl;
      var value = 0;

      await tester.pumpWidget(
        Momentum(
          child: MaterialApp(home: BasicListExamplePage()),
          enableLogging: true,
          key: UniqueKey(),
          restartCallback: () {
            value = 88;
          },
          controllers: [TodoExampleController(), basicCtrl],
          onResetAll: (context, resetAll) {
            todoCtrl = Momentum.controller<TodoExampleController>(context);
            resetAll(context);
          },
        ),
      );
      await tester.pumpAndSettle();

      basicCtrl.add('item 1');
      await tester.pumpAndSettle();
      expect(basicCtrl.model.list!.length, 1);

      basicCtrl.sendEvent(BasicListEvent.resetAll);
      await tester.pumpAndSettle();
      expect(basicCtrl.model.list!.length, 0);
      expect(todoCtrl != null, true);

      basicCtrl.sendEvent(BasicListEvent.restart);
      await tester.pumpAndSettle();
      expect(value, 88);
    });

    testWidgets('basic restart test', (tester) async {
      var basicCtrl = BasicListExampleController();
      var todoCtrl = TodoExampleController();
      Widget _rootWithRestart() {
        return Momentum(
          child: MaterialApp(
            home: BasicListExamplePage(),
          ),
          enableLogging: true,
          controllers: [basicCtrl, todoCtrl],
        );
      }

      await tester.pumpWidget(_rootWithRestart());
      await tester.pumpAndSettle();

      basicCtrl.add('item 1');
      await tester.pumpAndSettle();
      expect(basicCtrl.model.list!.length, 1);
      var item1 = find.byKey(Key('BasicItem-#0'));
      expect(item1, findsOneWidget);

      basicCtrl.add('item 2');
      await tester.pumpAndSettle();
      expect(basicCtrl.model.list!.length, 2);
      var item2 = find.byKey(Key('BasicItem-#1'));
      expect(item2, findsOneWidget);

      basicCtrl.sendEvent(RestartEvent(_rootWithRestart() as Momentum));
      await tester.pumpAndSettle();

      todoCtrl.addTodo('item 1');
      await tester.pumpAndSettle();
      expect(todoCtrl.model.todoMap!.length, 1);
    });
  });

  group('reset() & resetAll() regression tests', () {
    testWidgets('reset() on Equatable model rebuilds MomentumBuilder (clearHistory true & false), calls init() once, and passes isTimeTravel == false', (tester) async {
      var controller = _ResetEquatableController()..config(maxTimeTravelSteps: 5);
      var buildCount = 0;
      var listenerEvents = <bool>[];

      await tester.pumpWidget(
        Momentum(
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: _ResetListenerWidget(
                onListenerFired: (isTimeTravel) => listenerEvents.add(isTimeTravel),
                child: MomentumBuilder(
                  controllers: [_ResetEquatableController],
                  builder: (context, snapshot) {
                    buildCount++;
                    var model = snapshot<_ResetEquatableModel>();
                    return Text('val:${model.value}');
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.initCount, 1);
      expect(buildCount, 1);
      expect(find.text('val:0'), findsOneWidget);

      // Update to non-default value.
      controller.model.update(value: 42);
      await tester.pumpAndSettle();
      expect(buildCount, 2);
      expect(find.text('val:42'), findsOneWidget);
      expect(listenerEvents, [false]);

      // Reset with clearHistory: false -> init() called once more, MomentumBuilder rebuilds,
      // isTimeTravel is false, and previous model is preserved in history.
      controller.reset(clearHistory: false);
      await tester.pumpAndSettle();
      expect(controller.initCount, 2);
      expect(buildCount, 3);
      expect(find.text('val:0'), findsOneWidget);
      expect(controller.prevModel?.value, 42);
      expect(listenerEvents, [false, false]);

      // Reset again with clearHistory: true when model is already equal to initial (value == 0).
      // Must still call init() once, clear history, rebuild MomentumBuilder, and pass isTimeTravel == false.
      controller.reset(clearHistory: true);
      await tester.pumpAndSettle();
      expect(controller.initCount, 3);
      expect(buildCount, 4);
      expect(find.text('val:0'), findsOneWidget);
      expect(controller.prevModel, isNull);
      expect(controller.nextModel, isNull);
      expect(listenerEvents, [false, false, false]);
    });

    testWidgets('Momentum.resetAll forwards clearHistory through onResetAll (true & false)', (tester) async {
      var controller = _ResetEquatableController()..config(maxTimeTravelSteps: 5);
      var onResetAllCalls = 0;
      late BuildContext innerContext;

      await tester.pumpWidget(
        Momentum(
          controllers: [controller],
          onResetAll: (context, resetAll) {
            onResetAllCalls++;
            resetAll(context);
          },
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  innerContext = context;
                  return MomentumBuilder(
                    controllers: [_ResetEquatableController],
                    builder: (context, snapshot) {
                      var model = snapshot<_ResetEquatableModel>();
                      return Text('val:${model.value}');
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test clearHistory: false forwarded through onResetAll.
      controller.model.update(value: 10);
      await tester.pumpAndSettle();
      expect(find.text('val:10'), findsOneWidget);

      Momentum.resetAll(innerContext, clearHistory: false);
      await tester.pumpAndSettle();
      expect(onResetAllCalls, 1);
      expect(controller.model.value, 0);
      expect(controller.prevModel?.value, 10);
      expect(find.text('val:0'), findsOneWidget);

      // Test clearHistory: true forwarded through onResetAll.
      controller.model.update(value: 20);
      await tester.pumpAndSettle();
      expect(find.text('val:20'), findsOneWidget);

      Momentum.resetAll(innerContext, clearHistory: true);
      await tester.pumpAndSettle();
      expect(onResetAllCalls, 2);
      expect(controller.model.value, 0);
      expect(controller.prevModel, isNull);
      expect(controller.nextModel, isNull);
      expect(find.text('val:0'), findsOneWidget);
    });
  });

  group('event isolation, polymorphic dispatch & disposal', () {
    testWidgets('multiple listeners on the same type T all receive dispatched events', (tester) async {
      final controller = _EventTestController();
      final listener1Events = <String>[];
      final listener2Events = <String>[];
      final sameStateListenerA = <String>[];
      final sameStateListenerB = <String>[];

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  _TypedEventListener<_EventAlpha>(
                    onEvent: (event) => listener1Events.add(event.message),
                  ),
                  _TypedEventListener<_EventAlpha>(
                    onEvent: (event) => listener2Events.add(event.message),
                  ),
                  _DualAlphaEventListener(
                    onFirst: (event) => sameStateListenerA.add(event.message),
                    onSecond: (event) => sameStateListenerB.add(event.message),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.sendEvent(const _EventAlpha('first'));
      controller.sendEvent(const _EventAlpha('second'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(listener1Events, ['first', 'second']);
      expect(listener2Events, ['first', 'second']);
      expect(sameStateListenerA, ['first', 'second']);
      expect(sameStateListenerB, ['first', 'second']);
    });

    testWidgets('listeners for distinct event types are strictly isolated', (tester) async {
      final controller = _EventTestController();
      final alphaEvents = <String>[];
      final betaEvents = <int>[];
      final stringEvents = <String>[];
      final intEvents = <int>[];

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  _TypedEventListener<_EventAlpha>(
                    onEvent: (e) => alphaEvents.add(e.message),
                  ),
                  _TypedEventListener<_EventBeta>(
                    onEvent: (e) => betaEvents.add(e.code),
                  ),
                  _TypedEventListener<String>(
                    onEvent: stringEvents.add,
                  ),
                  _TypedEventListener<int>(
                    onEvent: intEvents.add,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.sendEvent(const _EventAlpha('only-alpha'));
      await tester.pumpAndSettle();
      expect(alphaEvents, ['only-alpha']);
      expect(betaEvents, isEmpty);
      expect(stringEvents, isEmpty);
      expect(intEvents, isEmpty);

      controller.sendEvent(const _EventBeta(200));
      await tester.pumpAndSettle();
      expect(alphaEvents, ['only-alpha']);
      expect(betaEvents, [200]);
      expect(stringEvents, isEmpty);
      expect(intEvents, isEmpty);

      controller.sendEvent('raw-string');
      controller.sendEvent(42);
      await tester.pumpAndSettle();
      expect(alphaEvents, ['only-alpha']);
      expect(betaEvents, [200]);
      expect(stringEvents, ['raw-string']);
      expect(intEvents, [42]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BaseEvent and SubEvent polymorphic dispatch succeeds without TypeError', (tester) async {
      final controller = _EventTestController();
      final baseReceived = <_BaseEvent>[];
      final subAReceived = <_SubEventA>[];
      final subBReceived = <_SubEventB>[];

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  _TypedEventListener<_BaseEvent>(onEvent: baseReceived.add),
                  _TypedEventListener<_SubEventA>(onEvent: subAReceived.add),
                  _TypedEventListener<_SubEventB>(onEvent: subBReceived.add),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dispatch concrete SubEventA -> BaseEvent and SubEventA listeners fire, SubEventB does not.
      const subA = _SubEventA('from-a');
      controller.sendEvent(subA);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(baseReceived, [subA]);
      expect(subAReceived, [subA]);
      expect(subBReceived, isEmpty);

      // Dispatch SubEventB typed statically as BaseEvent -> BaseEvent and SubEventB listeners fire, SubEventA does not.
      const subB = _SubEventB('from-b', 7);
      controller.sendEvent<_BaseEvent>(subB);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(baseReceived, [subA, subB]);
      expect(subAReceived, [subA]);
      expect(subBReceived, [subB]);

      // Dispatch BaseEvent directly -> only BaseEvent listener fires, neither SubEvent listener throws TypeError.
      const baseOnly = _BaseEvent('base-only');
      controller.sendEvent(baseOnly);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(baseReceived, [subA, subB, baseOnly]);
      expect(subAReceived, [subA]);
      expect(subBReceived, [subB]);
    });

    testWidgets('no callback delivery occurs after MomentumState disposal while mounted listeners stay active', (tester) async {
      final controller = _EventTestController();
      final firstReceived = <String>[];
      final secondReceived = <String>[];
      var showFirst = true;
      var showSecond = true;
      late StateSetter updateTree;

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  updateTree = setState;
                  return Column(
                    children: [
                      if (showFirst)
                        _TypedEventListener<_EventAlpha>(
                          key: const ValueKey('listener-1'),
                          onEvent: (e) => firstReceived.add(e.message),
                        ),
                      if (showSecond)
                        _TypedEventListener<_EventAlpha>(
                          key: const ValueKey('listener-2'),
                          onEvent: (e) => secondReceived.add(e.message),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.sendEvent(const _EventAlpha('before-dispose'));
      await tester.pumpAndSettle();
      expect(firstReceived, ['before-dispose']);
      expect(secondReceived, ['before-dispose']);

      // Dispose first MomentumState while keeping second mounted.
      updateTree(() => showFirst = false);
      await tester.pumpAndSettle();

      controller.sendEvent(const _EventAlpha('after-first-dispose'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(firstReceived, ['before-dispose']);
      expect(secondReceived, ['before-dispose', 'after-first-dispose']);

      // Dispose second MomentumState as well; dispatching must deliver nothing and throw nothing.
      updateTree(() => showSecond = false);
      await tester.pumpAndSettle();

      controller.sendEvent(const _EventAlpha('after-all-disposed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(firstReceived, ['before-dispose']);
      expect(secondReceived, ['before-dispose', 'after-first-dispose']);
    });
  });
}

class _ResetEquatableModel extends MomentumModel<_ResetEquatableController> {
  const _ResetEquatableModel(
    _ResetEquatableController controller, {
    required this.value,
  }) : super(controller);

  final int value;

  @override
  void update({int? value}) {
    _ResetEquatableModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is _ResetEquatableModel && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class _ResetEquatableController extends MomentumController<_ResetEquatableModel> {
  int initCount = 0;

  @override
  _ResetEquatableModel init() {
    initCount++;
    return _ResetEquatableModel(this, value: 0);
  }
}

class _ResetListenerWidget extends StatefulWidget {
  const _ResetListenerWidget({
    required this.onListenerFired,
    required this.child,
  });

  final void Function(bool isTimeTravel) onListenerFired;
  final Widget child;

  @override
  State<_ResetListenerWidget> createState() => _ResetListenerWidgetState();
}

class _ResetListenerWidgetState extends MomentumState<_ResetListenerWidget> {
  @override
  void initMomentumState() {
    var ctrl = Momentum.controller<_ResetEquatableController>(context);
    ctrl.addListener(
      state: this,
      invoke: (model, isTimeTravel) {
        widget.onListenerFired(isTimeTravel);
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _EventTestModel extends MomentumModel<_EventTestController> {
  const _EventTestModel(_EventTestController controller) : super(controller);

  @override
  void update() {
    _EventTestModel(controller).updateMomentum();
  }
}

class _EventTestController extends MomentumController<_EventTestModel> {
  @override
  _EventTestModel init() => _EventTestModel(this);
}

class _EventAlpha {
  final String message;
  const _EventAlpha(this.message);
}

class _EventBeta {
  final int code;
  const _EventBeta(this.code);
}

class _BaseEvent {
  final String label;
  const _BaseEvent(this.label);
}

class _SubEventA extends _BaseEvent {
  const _SubEventA(String label) : super(label);
}

class _SubEventB extends _BaseEvent {
  final int weight;
  const _SubEventB(String label, this.weight) : super(label);
}

class _TypedEventListener<T> extends StatefulWidget {
  const _TypedEventListener({
    Key? key,
    required this.onEvent,
  }) : super(key: key);

  final void Function(T event) onEvent;

  @override
  State<_TypedEventListener<T>> createState() => _TypedEventListenerState<T>();
}

class _TypedEventListenerState<T> extends MomentumState<_TypedEventListener<T>> {
  @override
  void initMomentumState() {
    Momentum.controller<_EventTestController>(context).listen<T>(
      state: this,
      invoke: widget.onEvent,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _DualAlphaEventListener extends StatefulWidget {
  const _DualAlphaEventListener({
    required this.onFirst,
    required this.onSecond,
  });

  final void Function(_EventAlpha event) onFirst;
  final void Function(_EventAlpha event) onSecond;

  @override
  State<_DualAlphaEventListener> createState() => _DualAlphaEventListenerState();
}

class _DualAlphaEventListenerState extends MomentumState<_DualAlphaEventListener> {
  @override
  void initMomentumState() {
    final ctrl = Momentum.controller<_EventTestController>(context);
    ctrl.listen<_EventAlpha>(state: this, invoke: widget.onFirst);
    ctrl.listen<_EventAlpha>(state: this, invoke: widget.onSecond);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
