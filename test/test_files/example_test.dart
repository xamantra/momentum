import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../example/lib/main.dart' as example;

void main() {
  testWidgets('example counter app renders and increments', (tester) async {
    await tester.pumpWidget(example.momentum());
    await tester.pumpAndSettle();

    expect(find.text('Momentum Counter'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byTooltip('Increment'));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });
}
