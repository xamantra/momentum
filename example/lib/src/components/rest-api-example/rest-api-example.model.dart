import 'package:momentum/momentum.dart';

import '../../data/index.dart';
import 'index.dart';

class RestApiExampleModel extends MomentumModel<RestApiExampleController> {
  RestApiExampleModel(
    RestApiExampleController controller, {
    this.todoList,
    this.isLoading,
  }) : super(controller);

  final TodoList todoList;
  final bool isLoading; // Used to display loading widget.

  @override
  void update({
    TodoList todoList,
    bool isLoading,
  }) {
    RestApiExampleModel(
      controller,
      todoList: todoList ?? this.todoList,
      isLoading: isLoading ?? this.isLoading,
    ).updateMomentum();
  }
}
