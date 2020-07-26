import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/src/momentum_error.dart';

import 'components/inject-service/inject-service.controller.dart';
import 'utilities/launcher.dart';
import 'widgets/inject_service.dart';
import 'widgets/service.dart';

void main() {
  testWidgets('Grab other service.', (tester) async {
    var widget = serviceWidget();
    await launch(tester, widget);
    var serviceA = widget.serviceForTest<ServiceA>();
    expect(serviceA, isInstanceOf<ServiceA>());
    var result = serviceA.increment(5);
    expect(result, 6);
    var resultFromServiceB = serviceA.times2(10);
    expect(resultFromServiceB, 20);
  });

  testWidgets('Grab services from injector', (tester) async {
    var widget = injectService();
    await launch(tester, widget);
    var calculatorWithoutLogs = widget.serviceForTest<CalculatorService>();
    expect(calculatorWithoutLogs.enableLogs, false);
    var calculatorWithLogs = widget.serviceForTest<CalculatorService>(
      alias: CalcAlias.enableLogs,
    );
    expect(calculatorWithLogs.enableLogs, true);
    calculatorWithoutLogs = widget.serviceForTest<CalculatorService>(
      alias: CalcAlias.disableLogs,
    );
    expect(calculatorWithoutLogs.enableLogs, false);
  });

  testWidgets('Grab services from injector: error test', (tester) async {
    var widget = injectService();
    await launch(tester, widget);
    await tester.tap(find.byKey(errorKey1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
    await tester.tap(find.byKey(errorKey2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
    await tester.tap(find.byKey(errorKey3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
    await tester.tap(find.byKey(errorKey4));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('Grab services from injector: from controller', (tester) async {
    var widget = injectService();
    await launch(tester, widget);
    var controller = widget.getController<InjectServiceController>();
    expect(controller, isInstanceOf<InjectServiceController>());
    var calculatorWithoutLogs = controller.getServiceWithoutLogs();
    expect(calculatorWithoutLogs.enableLogs, false);
    var calculatorWithLogs = controller.getServiceWithLogs();
    expect(calculatorWithLogs.enableLogs, true);
  });

  testWidgets('Inject Service: duplicate alias', (tester) async {
    var widget = injectService(duplicate: true);
    await launch(tester, widget);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });
}
