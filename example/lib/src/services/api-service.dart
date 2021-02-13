import 'package:dio/dio.dart';
import 'package:momentum/momentum.dart';

import '../data/index.dart';

/// An example of `MomentumService`.
/// You can access and use a specific service anywhere in the widget or the controllers.
class ApiService extends MomentumService {
  final dio = Dio();

  Future<TodoList> getTodoList({
    int timeout = 10000,
  }) async {
    try {
      var response = await dio.get(
        'https://jsonplaceholder.typicode.com/todos',
        options: Options(sendTimeout: timeout, receiveTimeout: timeout),
      );
      return TodoList.fromJson(response.data);
    } catch (e) {
      print(e);
      return TodoList(list: []);
    }
  }
}
