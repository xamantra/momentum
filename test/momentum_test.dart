import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_base.dart';

import 'components/counter/counter.controller.dart';
import 'components/router-param/index.dart';
import 'widgets/router_params.dart';

void main() {
  test('Momentum Tester Tool: Counter', () async {
    var tester = MomentumTester(
      controllers: [
        CounterController(),
      ],
    );

    await tester.init();

    var counter = tester.controller<CounterController>();
    expect(counter != null, true);
    expect(counter, isInstanceOf<CounterController>());
    expect(counter.model.value, 0);
    counter.increment();
    expect(counter.model.value, 1);
    counter.increment();
    counter.increment();
    counter.increment();
    expect(counter.model.value, 4);
    counter.decrement();
    expect(counter.model.value, 3);
  });

  test('Momentum Tester Tool: Router Param', () async {
    var tester = MomentumTester(
      controllers: [
        RouterParamController(),
      ],
      services: [
        Router([]),
      ],
    );

    await tester.init();

    var controller = tester.controller<RouterParamController>();
    expect(controller != null, true);
    expect(controller, isInstanceOf<RouterParamController>());
    tester.mockRouterParam(TestRouterParamsC('tester...'));
    var paramValue = controller.getParamValue();
    expect(paramValue, 'tester...');
    var paramErrorTest = controller.getParamErrorTest();
    expect(paramErrorTest, null);
  });
}
