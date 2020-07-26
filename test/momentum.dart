import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/src/momentum_error.dart';

import 'components/counter/counter.controller.dart';
import 'components/sync-test/index.dart';
import 'utilities/launcher.dart';
import 'widgets/blank_widget.dart';
import 'widgets/counter_obsolete.dart';
import 'widgets/counter_restart.dart';
import 'widgets/counter_restart_callback.dart';
import 'widgets/error_widget6.dart';
import 'widgets/error_widget7.dart';
import 'widgets/error_widget8.dart';
import 'widgets/reset_all.dart';
import 'widgets/reset_all_override.dart';

void main() {
  testWidgets('null controller specified in momentum', (tester) async {
    var widget = errorWidget6();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('null controllers and services', (tester) async {
    var widget = blankWidget();
    await launch(tester, widget);
    var blankText = find.text('Blank App');
    expect(blankText, findsOneWidget);
  });

  testWidgets('duplicate controller', (tester) async {
    var widget = errorWidget7();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('resetAll', (tester) async {
    var widget = resetAllWidget();
    await launch(tester, widget);
    var syncTest = widget.getController<SyncTestController>();
    expect(syncTest.model.value, 333);
    var counter = widget.getController<CounterController>();
    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(resetAllButtonKey));
    await tester.pumpAndSettle();
    expect(syncTest.model.value, 0);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Momentum.controller<T>(context)', (tester) async {
    var widget = errorWidget8();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('resetAll - override onResetAll', (tester) async {
    var widget = resetAllOverrideWidget();
    await launch(tester, widget);
    var syncTest = widget.getController<SyncTestController>();
    expect(syncTest.model.value, 333);
    var counter = widget.getController<CounterController>();
    counter.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    counter.increment();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(resetAllOverrideButtonKey));
    await tester.pumpAndSettle();
    expect(syncTest.model.value, 0);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('restart', (tester) async {
    var widget = counterRestart();
    await launch(tester, widget);
    await tester.tap(find.byKey(keyCounterIncrementButton));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(keyCounterIncrementButton));
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(keyRestartButton));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('restart callback', (tester) async {
    var widget = counterRestartCallback();
    await launch(tester, widget);
    await tester.tap(find.byKey(keyCounterIncrementButtonCallback));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(keyCounterIncrementButtonCallback));
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byKey(keyRestartButtonCallback));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('obsolete api: Momentum.of<T>', (tester) async {
    var widget = counterObsolete();
    await launch(tester, widget);
    await tester.tap(find.byKey(keyCounterObsoleteIncrement));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(keyCounterObsoleteIncrement));
    await tester.pump();
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });
}
