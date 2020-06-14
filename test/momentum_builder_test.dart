import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/src/momentum_error.dart';

import 'components/counter/counter.controller.dart';
import 'utilities/launcher.dart';
import 'widgets/error_widget.dart';
import 'widgets/error_widget2.dart';
import 'widgets/error_widget3.dart';
import 'widgets/error_widget4.dart';
import 'widgets/error_widget5.dart';
import 'widgets/skip_rebuild.dart';

void main() {
  testWidgets('null builder parameter', (tester) async {
    var widget = errorWidget();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });
  testWidgets('non existent controller error test', (tester) async {
    var widget = errorWidget2();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });
  testWidgets('dontRebuildIf test', (tester) async {
    var widget = skipRebuildWidget();
    await launch(tester, widget);
    expect(find.text('0'), findsOneWidget);
    var controller = widget.getController<CounterController>();
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
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });
  testWidgets('access a model but controller is not injected', (tester) async {
    var widget = errorWidget4();
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });
  testWidgets('dontRebuildIf access controller not injected', (tester) async {
    var widget = errorWidget5();
    await launch(tester, widget);
    var controller = widget.getController<CounterController>();
    try {
      controller.increment();
    } on dynamic catch (e) {
      expect(e is Exception, true);
    }
  });
}
