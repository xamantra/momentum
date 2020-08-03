// import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/src/momentum_base.dart';

import 'momentum_tester_components/tester1/index.dart';

void main() {
  test('Momentum Tester Tool', () async {
    var tester = MomentumTester(
      controllers: [
        Tester1Controller(),
      ],
    );

    await tester.init();

    var controller1 = tester.controller<Tester1Controller>();
    expect(controller1 != null, true);
    expect(controller1, isInstanceOf<Tester1Controller>());
    return;
  });
}
