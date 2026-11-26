import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/rest-api-example/index.dart';
import '../../../demo_app/services/index.dart';
import '../../utils.dart';

Dio _createMockDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final data = List.generate(
          200,
          (i) => {
            'userId': (i ~/ 20) + 1,
            'id': i + 1,
            'title': 'Mock todo ${i + 1}',
            'completed': i.isEven,
          },
        );
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: data,
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('<RestApiExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [RestApiExampleController()],
        services: [ApiService(null, _createMockDio())],
      ),
    );
    await tester.init();

    var controller = tester.controller<RestApiExampleController>()!;
    isControllerValid<RestApiExampleController>(controller);
    isModelValid<RestApiExampleModel>(controller.model);

    expect(controller.model.isLoading, false);
    expect(controller.model.todoList, null);

    var future = controller.loadTodoList();
    expect(controller.model.isLoading, true);
    await future.whenComplete(() {
      expect(controller.model.isLoading, false);
      expect(controller.model.todoList != null, true);
      expect(controller.model.todoList!.list!.length, 200);
    });
    controller.model.update(isLoading: null);
    expect(controller.model.isLoading, false);
  });
}
