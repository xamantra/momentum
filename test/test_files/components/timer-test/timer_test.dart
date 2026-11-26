import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/timer-example/index.dart';
import '../../utils.dart';

void main() {
  test('<TimerExampleController> component test', () {
    fakeAsync((async) {
      var tester = MomentumTester(
        Momentum(
          controllers: [TimerExampleController()],
        ),
      );
      tester.init();
      async.flushMicrotasks();

      var controller = tester.controller<TimerExampleController>()!;
      isControllerValid<TimerExampleController>(controller);
      isModelValid<TimerExampleModel>(controller.model);

      expect(controller.model.started, false);
      expect(controller.model.seconds, 0);
      expect(controller.model.controllerName, 'TimerExampleController');

      controller.startTimer();
      async.elapse(const Duration(seconds: 5));
      var state = controller.model;
      expect(state.started, true);
      expect(state.seconds, 5);

      controller.stopTimer();
      expect(controller.model.started, false);
      expect(controller.model.seconds, 0);
    });
  });
}
