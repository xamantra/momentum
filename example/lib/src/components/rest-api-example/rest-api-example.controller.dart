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

  void loadTodoList() async {
    // This is how you access a service from a controller. In widgets, you need a `context`.
    var api = service<ApiService>();

    // Take note `model.update(...)` also rebuilds the widget. In this stage, we are showing a loading widget by setting `isLoading` to "true".
    model.update(isLoading: true);

    // Load the todo list from an http api resource. Which while in progress, a loading indicator widget is being shown.
    var result = await api.getTodoList();

    // Finally, the todo data list has finished loading and it's time to hide the loading indicator widget and show the todo list widgets.
    model.update(isLoading: false, todoMap: result);
  }

  void loadTodoList_V2() async {
    // You can also access a model property.
    if (model.isLoading) {
      // If the controller is already loading the todo list, there's no need to process it again.
      // This traps a possible error of switching back and forth between pages.
      return;
    }

    // This is how you access a service from a controller. In widgets, you need a `context`.
    var api = service<ApiService>();

    // Take note `model.update(...)` also rebuilds the widget. In this stage, we are showing a loading widget by setting `isLoading` to "true".
    model.update(isLoading: true);

    // Load the todo list from an http api resource. Which while in progress, a loading indicator widget is being shown.
    var result = await api.getTodoList();

    // Finally, the todo data list has finished loading and it's time to hide the loading indicator widget and show the todo list widgets.
    model.update(isLoading: false, todoMap: result);
  }
}
