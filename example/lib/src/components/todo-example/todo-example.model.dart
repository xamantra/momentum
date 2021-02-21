import 'package:momentum/momentum.dart';

import 'index.dart';

class TodoExampleModel extends MomentumModel<TodoExampleController> {
  TodoExampleModel(
    TodoExampleController controller, {
    this.todoMap,
  }) : super(controller);

  final Map<String, bool> todoMap;

  @override
  void update({
    Map<String, bool> todoMap,
  }) {
    TodoExampleModel(
      controller,
      todoMap: todoMap ?? this.todoMap,
    ).updateMomentum();
  }

  Map<String, dynamic> toJson() {
    return {
      'todoMap': todoMap,
    };
  }

  TodoExampleModel fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return TodoExampleModel(
      controller,
      todoMap: Map<String, bool>.from(json['todoMap']),
    );
  }
}
