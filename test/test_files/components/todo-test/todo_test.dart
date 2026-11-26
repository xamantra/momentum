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

    var controller = tester.controller<TodoExampleController>()!;
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

    var controller = tester.controller<TodoExampleController>()!;
    isControllerValid<TodoExampleController>(controller);
    isModelValid<TodoExampleModel>(controller.model);

    expect(controller.model.todoMap, const {});
    controller.model.update(todoMap: null);
    expect(controller.model.todoMap, const {});

    controller.model.update(todoMap: const {'Test todo 1': false});
    expect(controller.model.todoMap, const {'Test todo 1': false});

    var json = controller.model.toJson();
    var parsedFromJson = controller.model.fromJson(json)!;
    expect(controller.model.todoMap, parsedFromJson.todoMap);
  });

  group('<TodoExampleModel> persistence test', () {
    Momentum _getRoot(Map<String, String?> memoryStorage) {
      return Momentum(
        controllers: [TodoExampleController()],
        enableLogging: true,
        persistSave: (context, key, value) async {
          memoryStorage[key] = value;
          return true;
        },
        persistGet: (context, key) async {
          return memoryStorage[key];
        },
      );
    }

    test('<TodoExampleModel> persistence test (save and restore)', () async {
      final memoryStorage = <String, String?>{};

      // 1st run: persist a todo
      var tester1 = MomentumTester(_getRoot(memoryStorage));
      await tester1.init();

      var controller1 = tester1.controller<TodoExampleController>()!;
      isControllerValid<TodoExampleController>(controller1);
      isModelValid<TodoExampleModel>(controller1.model);

      expect(controller1.model.todoMap, const {});

      controller1.addTodo('Test todo 1');
      expect(controller1.model.todoMap, const {'Test todo 1': false});

      // 2nd run: restore persisted todo in a fresh Momentum instance
      var tester2 = MomentumTester(_getRoot(memoryStorage));
      await tester2.init();

      var controller2 = tester2.controller<TodoExampleController>()!;
      isControllerValid<TodoExampleController>(controller2);
      isModelValid<TodoExampleModel>(controller2.model);

      expect(controller2.model.todoMap, const {'Test todo 1': false});
    });
  });
}
