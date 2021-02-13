import 'package:example/src/components/rest-api-example/index.dart';
import 'package:example/src/services/api-service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../utils.dart';

void main() {
  test('<RestApiExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [RestApiExampleController()],
        services: [ApiService()],
      ),
    );
    await tester.init();

    var controller = tester.controller<RestApiExampleController>();
    isControllerValid<RestApiExampleController>(controller);
    isModelValid<RestApiExampleModel>(controller.model);

    expect(controller.model.isLoading, false);
    expect(controller.model.todoList, null);

    var future = controller.loadTodoList();
    expect(controller.model.isLoading, true);
    await future.whenComplete(() {
      expect(controller.model.isLoading, false);
      expect(controller.model.todoList != null, true);
      expect(controller.model.todoList.list.length, 200);
    });
    return;
  });
}
