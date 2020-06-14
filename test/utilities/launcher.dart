import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> launch(
  WidgetTester tester,
  Widget widget, {
  int milliseconds,
}) async {
  await tester.pumpWidget(widget);
  if (milliseconds == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pumpAndSettle(Duration(milliseconds: milliseconds));
  }
}
