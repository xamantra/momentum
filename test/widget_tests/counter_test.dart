import 'package:flutter_test/flutter_test.dart';

import '../components/counter/index.dart';
import '../utilities/launcher.dart';
import '../widgets/counter.dart';

void main() {
  testWidgets('Start Widget', (tester) async {
    var widget = counter();
    await inject(tester, widget);
    var valueFinder = find.byKey(keyCounterValue);
    var incrementFinder = find.byKey(keyIncrementButton);
    expect(valueFinder, findsOneWidget);
    expect(incrementFinder, findsOneWidget);
  });

  testWidgets('Click Increment', (tester) async {
    var widget = counter();
    await inject(tester, widget);
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
    await inject(tester, widget);
    var controller = widget.controllerForTest<CounterController>();
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
    await inject(tester, widget);
    var controller = widget.controllerForTest<CounterController>();
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
