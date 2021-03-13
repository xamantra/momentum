import 'package:momentum/momentum.dart';

import '../../services/index.dart';
import 'index.dart';

class RestApiExampleController extends MomentumController<RestApiExampleModel> {
  @override
  RestApiExampleModel init() {
    return RestApiExampleModel(
      this,
      isLoading: false,
    );
  }

  Future<void> loadTodoList() async {
    if (model.isLoading) {
      return;
    }
    var api = service<ApiService>();
    model.update(isLoading: true);
    var result = await api.getTodoList();
    model.update(isLoading: false, todoMap: result);
  }
}
