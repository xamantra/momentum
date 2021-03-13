import 'package:momentum/momentum.dart';

import '../components/basic-list-example/index.dart';
import '../components/calculator-example/index.dart';
import '../components/rest-api-example/index.dart';
import '../components/timer-example/index.dart';
import '../components/todo-example/index.dart';

List<MomentumController> controllers() {
  return [
    TimerExampleController(),
    RestApiExampleController(),
    BasicListExampleController()..config(maxTimeTravelSteps: 100),
    TodoExampleController(),
    CalculatorExampleController(),
  ];
}
