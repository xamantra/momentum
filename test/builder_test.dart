import 'package:flutter_test/flutter_test.dart';

import 'components/counter/counter.controller.dart';
import 'utility.dart';
import 'widgets/error_widget.dart';
import 'widgets/error_widget2.dart';
import 'widgets/error_widget3.dart';
import 'widgets/skip_rebuild.dart';

void main() {
  testWidgets('null builder parameter', (tester) async {
    var widget = errorWidget();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
  testWidgets('non existent controller error test', (tester) async {
    var widget = errorWidget2();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
  testWidgets('dontRebuildIf test', (tester) async {
    var widget = skipRebuildWidget();
    await inject(tester, widget);
    expect(find.text('0'), findsOneWidget);
    var controller = widget.controllerForTest<CounterController>();
    controller.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    controller.increment();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    controller.increment();
    await tester.pump();
    expect(find.text('3'), findsNothing);
  });
  testWidgets('null controllers', (tester) async {
    var widget = errorWidget3();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
}
