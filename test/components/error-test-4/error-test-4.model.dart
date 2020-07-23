import 'package:momentum/momentum.dart';

import 'index.dart';

class ErrorTest4Model extends MomentumModel<ErrorTest4Controller> {
  ErrorTest4Model(ErrorTest4Controller controller) : super(controller);

  @override
  void update() {
    ErrorTest4Model(
      controller,
    ).updateMomentum();
  }
}
