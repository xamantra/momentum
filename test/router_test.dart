import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import 'utility.dart';
import 'widgets/router_error_widget.dart';
import 'widgets/router_test_widget.dart';

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

    testWidgets('Pop', (tester) async {
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
  });
}
