import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../demo_app/services/index.dart';

Dio _createMockDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == 'https://jsonplaceholder.typicode.com/todos') {
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
          return;
        }
        handler.reject(
          DioException(
            requestOptions: options,
            error: ArgumentError('No host specified in URI ${options.path}'),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('<ApiService> test', () async {
    var tester = MomentumTester(
      Momentum(controllers: [], services: [ApiService(null, _createMockDio())]),
    );
    await tester.init();

    var api = tester.service<ApiService>();
    expect(api, isInstanceOf<ApiService>());

    var response = await api.getTodoList();
    expect(response.list!.isNotEmpty, true);
    expect(response.list!.length, 200);

    // test http error
    var errorResult = await api.getTodoList(mockUrl: '');
    expect(errorResult.list, const []);

    api = tester.service(runtimeType: false);
    expect(api, isInstanceOf<ApiService>());
  });
}
