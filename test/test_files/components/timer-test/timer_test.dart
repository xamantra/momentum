import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/timer-example/index.dart';
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
    expect(controller.model.controllerName, 'TimerExampleController');

    controller.startTimer();
    await Future.delayed(Duration(milliseconds: 5100));
    var state = controller.model;
    expect(state.started, true);
    expect(state.seconds, 5);

    controller.stopTimer();
    expect(controller.model.started, false);
    expect(controller.model.seconds, 0);
  });
}
