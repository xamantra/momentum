import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import 'utility.dart';
import 'widgets/router_error_widget.dart';
import 'widgets/router_exit.dart';
import 'widgets/router_test_widget.dart';
import 'widgets/router_transition.dart';

void main() {
  group("Router Test", () {
    testWidgets('Initialize', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
    });

    testWidgets('#1 goto(...)', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(gotoPageBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('Restart', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
    });

    testWidgets('#2 goto(...)', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageB, true);
      await tester.tap(find.byKey(gotoPageCKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageC, true);
    });

    testWidgets('pop', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(fromPageCPop));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });

    testWidgets('#3 goto(...): error test', (tester) async {
      var widget = routerErrorTest();
      await inject(tester, widget);
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
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageExitTest, true);
      await tester.tap(find.byKey(routerExitButtonKey));
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('#1 transition goto(...)', (tester) async {
      var widget = routerTransitionTest();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is TransitionPageA, true);
      await tester.tap(find.byKey(transitionToBKey));
      await tester.pumpAndSettle();
      expect(router.getActive() is TransitionPageB, true);
    });

    testWidgets('transition Restart', (tester) async {
      var widget = routerTransitionTest();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is TransitionPageB, true);
    });

    testWidgets('#2 transition goto(...)', (tester) async {
      var widget = routerTransitionTest();
      await inject(tester, widget);
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
      await inject(tester, widget);
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
      await inject(tester, widget);
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
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
    });

    testWidgets('clearHistoryWithContext', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageC, true);
      await tester.tap(find.byKey(clearHistoryButton));
      await tester.pumpAndSettle();
      expect(router.isRoutesEmpty, true);
    });

    testWidgets('resetWithContext', (tester) async {
      var widget = routerTestWidget();
      await inject(tester, widget);
      var router = widget.serviceForTest<Router>();
      expect(router == null, false);
      expect(router.getActive() is PageA, true);
      await tester.tap(find.byKey(resetHistoryButton));
      await tester.pumpAndSettle();
      expect(router.getActive() is PageB, true);
    });
  });
}
