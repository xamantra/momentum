import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/widgets/pages/example-basic-list/index.dart';

void main() {
  group('event system', () {
    var _basicListCtrl = BasicListExampleController()..config(maxTimeTravelSteps: 10);
    Widget _root() {
      return Momentum(
        child: MaterialApp(
          home: BasicListExamplePage(),
        ),
        enableLogging: true,
        controllers: [_basicListCtrl],
      );
    }

    testWidgets('test controller->widget event system', (tester) async {
      await tester.pumpWidget(_root());
      await tester.pumpAndSettle();

      _basicListCtrl.add('item 1');
      _basicListCtrl.add('item 2');
      _basicListCtrl.add('item 3');
      expect(_basicListCtrl.model.list!.length, 3);

      expect(_basicListCtrl.model.list!.first, 'item 1');
      expect(_basicListCtrl.model.list!.last, 'item 3');
      _basicListCtrl.sendEvent(BasicListEvent.reverseList);
      await tester.pumpAndSettle();
      expect(_basicListCtrl.model.list!.first, 'item 3');
      expect(_basicListCtrl.model.list!.last, 'item 1');

      _basicListCtrl.sendEvent(BasicListEvent.clearList);
      await tester.pumpAndSettle();
      expect(_basicListCtrl.model.list!.length, 0);
    });

    testWidgets('resetAll(context)->widget event system', (tester) async {
      await tester.pumpWidget(_root());
      await tester.pumpAndSettle();

      _basicListCtrl.add('item 1');
      _basicListCtrl.add('item 2');
      _basicListCtrl.add('item 3');
      expect(_basicListCtrl.model.list!.length, 3);
      expect(_basicListCtrl.model.list!.first, 'item 1');
      expect(_basicListCtrl.model.list!.last, 'item 3');

      _basicListCtrl.sendEvent(BasicListEvent.resetAll);
      await tester.pumpAndSettle();
      expect(_basicListCtrl.model.list!.length, 0);
      expect(_basicListCtrl.prevModel!.list!.length, 3);

      _basicListCtrl.add('item 1');
      _basicListCtrl.add('item 2');
      _basicListCtrl.add('item 3');
      expect(_basicListCtrl.model.list!.length, 3);
      expect(_basicListCtrl.model.list!.first, 'item 1');
      expect(_basicListCtrl.model.list!.last, 'item 3');

      _basicListCtrl.sendEvent(BasicListEvent.resetAllClearHistory);
      await tester.pumpAndSettle();
      expect(_basicListCtrl.model.list!.length, 0);
      expect(_basicListCtrl.prevModel, null);
      expect(_basicListCtrl.nextModel, null);
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
}
