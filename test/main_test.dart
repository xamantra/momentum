import 'package:flutter_test/flutter_test.dart';

import 'counter.dart' as counter_test;
import 'momentum.dart' as momentum;
import 'momentum_builder.dart' as momentum_builder_test;
import 'momentum_controller.dart' as momentum_controller_test;
import 'momentum_model.dart' as momentum_model_test;
import 'momentum_service.dart' as momentum_service_test;
import 'router.dart' as router_test;
import 'types.dart' as types;
import 'types_one_builder.dart' as types_one_builder_test;

void main() {
  group("Momentum Tests", () {
    counter_test.main();
    momentum_builder_test.main();
    momentum_controller_test.main();
    momentum_model_test.main();
    momentum_service_test.main();
    momentum.main();
    router_test.main();
    types_one_builder_test.main();
    types.main();
  });
}
