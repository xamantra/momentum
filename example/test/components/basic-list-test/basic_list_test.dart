import 'package:example/src/components/basic-list-example/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../utils.dart';

void main() {
  test('<BasicListExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          BasicListExampleController()..config(maxTimeTravelSteps: 10),
        ],
      ),
    );
    await tester.init();

    var controller = tester.controller<BasicListExampleController>();
    isControllerValid<BasicListExampleController>(controller);
    isModelValid<BasicListExampleModel>(controller.model);

    expect(controller.model.list, []);

    controller.addNewRandom();
    expect(controller.model.list.length, 1);
    controller.addNewRandom();
    expect(controller.model.list.length, 2);
    controller.addNewRandom();
    controller.addNewRandom();
    controller.addNewRandom();
    controller.addNewRandom();
    expect(controller.model.list.length, 6);

    // undo/redo tests
    controller.undo();
    expect(controller.model.list.length, 5);
    controller.undo();
    expect(controller.model.list.length, 4);
    controller.redo();
    expect(controller.model.list.length, 5);
    controller.redo();
    expect(controller.model.list.length, 6);

    // remove item test
    var secondItem = controller.model.list[1];
    expect(controller.model.list.any((x) => x == secondItem), true);
    controller.remove(1);
    expect(controller.model.list.any((x) => x == secondItem), false);
  });
}
