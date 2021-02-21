// This file is generated with the help of these links:
//
// https://jsonplaceholder.typicode.com/todos
// https://app.quicktype.io/

class TodoList {
  TodoList({
    this.list,
  });

  final List<TodoItem> list;

  TodoList copyWith({
    List<TodoItem> list,
  }) =>
      TodoList(
        list: list ?? this.list,
      );

  factory TodoList.fromJson(dynamic json) => TodoList(
        list: List<TodoItem>.from((json as List).map((x) => TodoItem.fromJson(x))),
      );
}

class TodoItem {
  const TodoItem({
    this.userId,
    this.id,
    this.title,
    this.completed,
  });

  final int userId;
  final int id;
  final String title;
  final bool completed;

  TodoItem copyWith({
    int userId,
    int id,
    String title,
    bool completed,
  }) =>
      TodoItem(
        userId: userId ?? this.userId,
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        userId: json["userId"] == null ? null : json["userId"],
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        completed: json["completed"] == null ? null : json["completed"],
      );
}
