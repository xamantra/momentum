import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../demo_app/src/_config/index.dart';
import '../../demo_app/src/components/basic-list-example/index.dart';
import '../../demo_app/src/widgets/pages/home/index.dart';

void main() {
  testWidgets('basic list page route param test', (tester) async {
    var basicCtrl = BasicListExampleController();
    await tester.pumpWidget(Momentum(
      child: MaterialApp(
        home: HomePage(),
      ),
      controllers: [
        basicCtrl,
      ],
      services: [
        MomentumRouter(routes),
      ],
    ));
    await tester.pumpAndSettle();

    var menuItems = find.byKey(basicListMenuKey);
    await tester.tap(menuItems);
    await tester.pumpAndSettle();

    var title = find.text('Basic List (routed)');
    expect(title, findsOneWidget);

    await tester.pumpAndSettle();
    expect(basicCtrl.latestList, 'Flutter,Dart,Google');
  });
}
