import 'package:example/src/components/todo-example/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../utils.dart';

void main() {
  test('<TodoExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [TodoExampleController()],
      ),
    );
    await tester.init();

    var controller = tester.controller<TodoExampleController>();
    isControllerValid<TodoExampleController>(controller);
    isModelValid<TodoExampleModel>(controller.model);

    expect(controller.model.todoMap, const {});

    controller.addTodo('Test todo 1');
    expect(controller.model.todoMap, const {'Test todo 1': false});

    controller.addTodo('Test todo 2');
    expect(controller.model.todoMap, const {
      'Test todo 1': false,
      'Test todo 2': false,
    });

    controller.toggleTodo('Test todo 2', true);
    expect(controller.model.todoMap, const {
      'Test todo 1': false,
      'Test todo 2': true,
    });

    controller.removeTodo('Test todo 1');
    expect(controller.model.todoMap, const {'Test todo 2': true});
  });
}
