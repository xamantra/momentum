import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_error.dart';

void main() {
  testWidgets('test Momentum\'s `initializer` parameter', (tester) async {
    var value = 0;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        initializer: () async {
          value = 99;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(value, 99);
  });

  testWidgets('test Momentum\'s `initializer` parameter with error', (tester) async {
    var value = 0;
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        initializer: () async {
          value = int.parse('dwdw');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(value, 0);
    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  test('test Momentum\'s `initializer` parameter with MomentumTester', () async {
    var value = 0;
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        initializer: () async {
          value = 99;
        },
      ),
    );
    await tester.init();

    expect(value, 99);
  });

  test('test Momentum\'s `initializer` parameter error with MomentumTester', () async {
    var value = 0;
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        initializer: () async {
          value = int.parse('dwdw');
        },
      ),
    );

    try {
      await tester.init();
    } catch (e) {
      expect(e, isInstanceOf<MomentumError>());
    }

    expect(value, 0);
  });
}
