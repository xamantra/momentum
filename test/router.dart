import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import 'utilities/launcher.dart';
import 'widgets/router_error_widget.dart';
import 'widgets/router_exit.dart';
import 'widgets/router_page_test_pop.dart';
import 'widgets/router_params.dart';
import 'widgets/router_test_widget.dart';
import 'widgets/router_transition.dart';

void main() {
  group("Router Test", () {
    testWidgets('Initialize', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
    });

    testWidgets('#1 goto(...)', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(gotoPageBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('Restart', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
    });

    testWidgets('#2 goto(...)', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
      await tester.tap(find.byKey(gotoPageCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageC, true);
    });

    testWidgets('pop', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(fromPageCPop));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('#3 goto(...): error test', (tester) async {
      var widget = routerErrorTest();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageErrorTestA, true);
      await tester.tap(find.byKey(errorTestGotoPageBKey));
      await tester.pumpAndSettle();
      var active = router.getActive();
      expect(active is PageErrorTestA, true);
    });

    testWidgets('#2 pop(...): exit app', (tester) async {
      var widget = routerExitApp();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageExitTest, true);
      await tester.tap(find.byKey(routerExitButtonKey));
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('#1 transition goto(...)', (tester) async {
      var widget = routerTransitionTest();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is TransitionPageA, true);
      await tester.tap(find.byKey(transitionToBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is TransitionPageB, true);
    });

    testWidgets('transition Restart', (tester) async {
      var widget = routerTransitionTest();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is TransitionPageB, true);
    });

    testWidgets('#2 transition goto(...)', (tester) async {
      var widget = routerTransitionTest();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is TransitionPageB, true);
      await tester.tap(find.byKey(transitionToCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is TransitionPageC, true);
      await tester.tap(find.byKey(transitionCPop));
      await tester.pumpAndSettle();
      expect(router.getActive() is TransitionPageB, true);
    });

    testWidgets('goto and clear history', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
      await tester.tap(find.byKey(gotoPageCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageC, true);
      router.clearHistory();
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('#1 router reset', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(gotoPageBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
      router.reset<PageC>();
      await tester.pumpAndSettle();
    });

    testWidgets('#2 router reset', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
    });

    testWidgets('clearHistoryWithContext', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(clearHistoryButton));
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('resetWithContext', (tester) async {
      var widget = routerTestWidget();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(resetHistoryButton));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('RouterPage Test', (tester) async {
      var widget = routerPageTest();
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is RouterPageA, true);
      await tester.tap(find.byKey(gotoRouterPageB));
      await tester.pumpAndSettle();
      expect(router.getActive() is RouterPageB, true);
      await tester.tap(find.byKey(gotoRouterPopKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is RouterPageA, true);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });
  });

  group("Router Test: testModeParam", () {
    testWidgets('Initialize', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
    });

    testWidgets('#1 goto(...)', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(gotoPageBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('Restart', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
    });

    testWidgets('#2 goto(...)', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
      await tester.tap(find.byKey(gotoPageCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageC, true);
    });

    testWidgets('pop', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(fromPageCPop));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('goto and clear history', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
      await tester.tap(find.byKey(gotoPageCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageC, true);
      router.clearHistory();
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('#1 router reset', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(gotoPageBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
      router.reset<PageC>();
      await tester.pumpAndSettle();
    });

    testWidgets('#2 router reset', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
    });

    testWidgets('clearHistoryWithContext', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(clearHistoryButton));
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('resetWithContext', (tester) async {
      var widget = routerTestWidget(
        testMode: true,
        sessionName: 'routerTestWidget: testModeParam',
      );
      await launch(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(resetHistoryButton));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });
  });

  testWidgets('Router params test', (tester) async {
    var widget = routerParamsTest('Router params test');
    await launch(tester, widget);
    expect(find.text('RouterParamsTestA'), findsOneWidget);
    expect(find.text('fail test'), findsNothing);
    await tester.tap(find.byKey(routerParamsBTestButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('Router params error test', (tester) async {
    var widget = routerParamsTest('Router params error test');
    await launch(tester, widget);
    expect(find.text('RouterParamsTestA'), findsOneWidget);
    expect(find.text('fail test'), findsNothing);
    await tester.tap(find.byKey(routerParamsCTestButtonKey));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isInstanceOf<NoSuchMethodError>());
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsNothing);
  });

  testWidgets('Router params controller test', (tester) async {
    var widget = routerParamsTest('Router params controller test');
    await launch(tester, widget);
    expect(find.text('RouterParamsTestA'), findsOneWidget);
    expect(find.text('fail test'), findsNothing);
    await tester.tap(find.byKey(routerParamsDTestButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsNothing);
    expect(find.text('Flutter is awesome!'), findsOneWidget);
    await tester.tap(find.byKey(routerParamsDErrorButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsNothing);
    expect(find.text('12345'), findsOneWidget);
  });

  testWidgets('Router params pop controller test', (tester) async {
    var widget = routerParamsTest('Router params pop controller test');
    await launch(tester, widget);
    expect(find.text('RouterParamsTestA'), findsOneWidget);
    expect(find.text('fail test'), findsNothing);
    await tester.tap(find.byKey(routerParamsDTestButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsNothing);
    expect(find.text('Flutter is awesome!'), findsOneWidget);
    await tester.tap(find.byKey(routerParamsDErrorButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('RouterParamsTestA'), findsNothing);
    expect(find.text('Hello World'), findsNothing);
    expect(find.text('12345'), findsOneWidget);
    await tester.tap(find.byKey(routerParamsPopButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('789'), findsOneWidget);
  });
}
