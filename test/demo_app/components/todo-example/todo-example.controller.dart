import 'package:momentum/momentum.dart';

import '../basic-list-example/index.dart';
import 'index.dart';

class TodoExampleController extends MomentumController<TodoExampleModel> {
  @override
  TodoExampleModel init() {
    return TodoExampleModel(
      this,
      todoMap: {},
    );
  }

  String eventTodoName = '';

  void addTodo(String title) {
    var todoList = Map<String, bool>.from(model.todoMap!);
    todoList.putIfAbsent(title, () => false);
    model.update(todoMap: todoList);
  }

  void addOnBasicList(String name) {
    controller<BasicListExampleController>().add(name);
  }

  void removeTodo(String title) {
    var todoList = Map<String, bool>.from(model.todoMap!);
    todoList.remove(title);
    model.update(todoMap: todoList);
  }

  void toggleTodo(String title, bool value) {
    var todoList = Map<String, bool>.from(model.todoMap!);
    todoList[title] = value;
    model.update(todoMap: todoList);
  }
}
