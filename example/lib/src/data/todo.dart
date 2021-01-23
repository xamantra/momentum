// This file is generated with the help of these links:
//
// https://jsonplaceholder.typicode.com/todos
// https://app.quicktype.io/

import 'dart:convert';

class TodoList {
  TodoList({
    this.list,
  });

  final List<TodoItem> list;

  TodoList copyWith({
    List<TodoItem> todo,
  }) =>
      TodoList(
        list: todo ?? this.list,
      );

  factory TodoList.fromJson(dynamic json) => TodoList(
        list: List<TodoItem>.from((json as List).map((x) => TodoItem.fromJson(x))),
      );
}

class TodoItem {
  TodoItem({
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

  factory TodoItem.fromRawJson(String str) => TodoItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        userId: json["userId"] == null ? null : json["userId"],
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        completed: json["completed"] == null ? null : json["completed"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId == null ? null : userId,
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "completed": completed == null ? null : completed,
      };
}
