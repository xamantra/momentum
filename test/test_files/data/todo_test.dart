import 'package:flutter_test/flutter_test.dart';

import '../../demo_app/data/index.dart';

void main() {
  test('<TodoList> data model test', () {
    var todoList = TodoList();
    expect(todoList.list, null);

    todoList = todoList.copyWith(
      list: const [
        const TodoItem(userId: 1, id: 1, title: 'Test 1', completed: true),
      ],
    );
    expect(todoList.list.length, 1);

    todoList = todoList.copyWith(list: null);
    expect(todoList.list.length, 1);
  });

  test('<TodoItem> data model test', () {
    var todoItem = TodoItem();
    expect(todoItem.id, null);

    todoItem = todoItem.copyWith(userId: 1, id: 1, title: 'Test 1', completed: true);
    expect(todoItem.id, 1);

    todoItem = todoItem.copyWith(id: null);
    expect(todoItem.id, 1);
  });
}
