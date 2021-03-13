import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/todo-example/index.dart';
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

  test('<TodoExampleModel> component test', () async {
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
    controller.model.update(todoMap: null);
    expect(controller.model.todoMap, const {});

    controller.model.update(todoMap: const {'Test todo 1': false});
    expect(controller.model.todoMap, const {'Test todo 1': false});

    var json = controller.model.toJson();
    var parsedFromJson = controller.model.fromJson(json);
    expect(controller.model.todoMap, parsedFromJson.todoMap);
  });

  test('<TodoExampleModel> persistence test (1st run)', () async {
    var tester = MomentumTester(_getRoot());
    await tester.init();

    var controller = tester.controller<TodoExampleController>();
    isControllerValid<TodoExampleController>(controller);
    isModelValid<TodoExampleModel>(controller.model);

    expect(controller.model.todoMap, const {});

    controller.addTodo('Test todo 1');
    expect(controller.model.todoMap, const {'Test todo 1': false});
  });

  test('<TodoExampleModel> persistence test (2nd run)', () async {
    var tester = MomentumTester(_getRoot());
    await tester.init();

    var controller = tester.controller<TodoExampleController>();
    isControllerValid<TodoExampleController>(controller);
    isModelValid<TodoExampleModel>(controller.model);

    expect(controller.model.todoMap, const {'Test todo 1': false});
  });
}

final _memoryStorage = <String, String>{};

Momentum _getRoot() {
  return Momentum(
    controllers: [TodoExampleController()],
    enableLogging: true,
    persistSave: (context, key, value) async {
      _memoryStorage.addAll({key: value});
      return true;
    },
    persistGet: (context, key) async {
      try {
        return _memoryStorage[key];
      } catch (e) {
        return null;
      }
    },
  );
}
