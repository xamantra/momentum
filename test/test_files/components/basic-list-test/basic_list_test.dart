import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/basic-list-example/index.dart';
import '../../../demo_app/widgets/pages/example-basic-list-routed/index.dart';
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
    expect(controller.model.list.length, 5);

    controller.model.update(list: null);
    expect(controller.model.list.length, 5);
  });

  test('<BasicListExampleController> router param test', () async {
    var basicCtrl = BasicListExampleController();
    var tester = MomentumTester(
      Momentum(
        controllers: [
          basicCtrl,
        ],
        services: [MomentumRouter([])],
      ),
    );
    await tester.init();

    tester.mockRouterParam(BasicListRouteParam(['Apple', 'Orange']));

    expect(basicCtrl.latestList, 'Apple,Orange');
  });

  testWidgets('<BasicListExampleController> non lazy controller', (tester) async {
    var basicCtrl = BasicListExampleController()..config(lazy: false);
    expect(basicCtrl.value, 0);
    expect(basicCtrl.value2, 0);

    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(),
        ),
        controllers: [basicCtrl],
      ),
    );
    await tester.pumpAndSettle();

    expect(basicCtrl.value, 99);
    expect(basicCtrl.value2, 88);
  });
}
