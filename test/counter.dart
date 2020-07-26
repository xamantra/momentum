import 'package:flutter_test/flutter_test.dart';

import 'components/counter/index.dart';
import 'utilities/launcher.dart';
import 'widgets/counter.dart';

void main() {
  testWidgets('Testing Initialization', (tester) async {
    var widget = counter();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    var counterController = widget.getController<CounterController>();
    expect(counterController, isInstanceOf<CounterController>());
    expect(counterController.model.value, 0);
  });

  testWidgets('Testing Functions', (tester) async {
    var widget = counter();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    var counterController = widget.getController<CounterController>();
    counterController.increment();
    expect(counterController.model.value, 1);
    counterController.increment();
    expect(counterController.model.value, 2);
  });

  testWidgets('Start Widget', (tester) async {
    var widget = counter();
    await launch(tester, widget);
    var valueFinder = find.byKey(keyCounterValue);
    var incrementFinder = find.byKey(keyIncrementButton);
    expect(valueFinder, findsOneWidget);
    expect(incrementFinder, findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Click Increment', (tester) async {
    var widget = counter();
    await launch(tester, widget);
    await tester.tap(find.byKey(keyIncrementButton));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(keyIncrementButton));
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Trigger Increment', (tester) async {
    var widget = counter();
    await launch(tester, widget);
    var controller = widget.getController<CounterController>();
    controller.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    controller.increment();
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Trigger Decrement', (tester) async {
    var widget = counter();
    await launch(tester, widget);
    var controller = widget.getController<CounterController>();
    controller.decrement();
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);
    controller.increment();
    await tester.pump();
    expect(find.text('-1'), findsNothing);
    expect(find.text('0'), findsOneWidget);
    controller.decrement();
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);
    controller.decrement();
    await tester.pump();
    expect(find.text('-2'), findsOneWidget);
  });
}
