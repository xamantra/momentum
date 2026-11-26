import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../demo_app/components/todo-example/index.dart';
import '../../demo_app/widgets/pages/example-todo/index.dart';

void main() {
  testWidgets('Todo page - state listener test', (tester) async {
    final memoryStorage = <String, String?>{};
    var controller = TodoExampleController();

    await tester.pumpWidget(_getRoot(controller, memoryStorage));
    await tester.pumpAndSettle();

    await _addTodo(tester, 'Todo 1');
    expect(controller.eventTodoName, 'Todo 1');

    await _addTodo(tester, 'Todo 99');
    expect(controller.eventTodoName, 'Todo 99');

    await _addTodo(tester, 'hello! world');
    expect(controller.eventTodoName, 'hello! world');

    // test persistence (restart with new key)
    controller = TodoExampleController();
    var key = UniqueKey();
    await tester.pumpWidget(_getRoot(controller, memoryStorage, key));
    await tester.pumpAndSettle();
    expect(controller.eventTodoName, 'hello! world');

    // test normal rebuild. shouldn't not change anything.
    await tester.pumpWidget(_getRoot(controller, memoryStorage, key));
    await tester.pumpAndSettle();
    // expecting the same values ...
    expect(controller.eventTodoName, 'hello! world');
  });
}

Momentum _getRoot(TodoExampleController controller, Map<String, String?> memoryStorage, [Key? key]) {
  return Momentum(
    key: key,
    child: MaterialApp(
      home: TodoExamplePage(),
    ),
    controllers: [controller],
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

Future<void> _addTodo(WidgetTester tester, String title) async {
  // tab the + FAB button to trigger `Add Todo Prompt`
  var fab = find.byType(FloatingActionButton);
  expect(fab, findsOneWidget);
  await tester.tap(fab);
  await tester.pumpAndSettle();

  // check if the add todo prompt was properly triggered along with the text input field.
  var todoPrompt = find.byType(AddTodoPrompt);
  expect(todoPrompt, findsOneWidget);
  var input = find.byType(TextFormField);
  expect(input, findsOneWidget);

  // type the todo title with the keyboard
  await tester.showKeyboard(input);
  tester.testTextInput.register();
  tester.testTextInput.enterText(title);

  // tap the `Add` button.
  var button = find.byType(TextButton);
  expect(button, findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
}
