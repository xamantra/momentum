import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> inject(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}
