import 'package:example/src/components/timer-example/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../utils.dart';

void main() {
  test('<TimerExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [TimerExampleController()],
      ),
    );
    await tester.init();

    var controller = tester.controller<TimerExampleController>();
    isControllerValid<TimerExampleController>(controller);
    isModelValid<TimerExampleModel>(controller.model);

    expect(controller.model.started, false);
    expect(controller.model.seconds, 0);

    controller.startTimer();
    await Future.delayed(Duration(seconds: 5));
    var state = controller.model;
    expect(state.started, true);
    // expected steps: 0, 1, 2, 3, 4 => (5 seconds)
    expect(state.seconds, 4);

    controller.stopTimer();
    expect(controller.model.started, false);
    expect(controller.model.seconds, 0);
  });
}
