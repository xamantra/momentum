import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/dummy/index.dart';

void main() {
  testWidgets('misconfigured json serializers.', (tester) async {
    await tester.pumpWidget(_root());
    await tester.pumpAndSettle();

    _dummyController.model.update(value: 4);
    expect(_dummyController.model.value, 4);
  });
}

var _dummyController = DummyController();

Momentum _root() {
  return Momentum(
    child: MaterialApp(home: Scaffold()),
    controllers: [_dummyController],
    enableLogging: true,
    persistSave: (context, key, value) async {
      expect(value, null);
      return true;
    },
    persistGet: (context, key) async {
      return '{}';
    },
  );
}
