import 'package:momentum/momentum.dart';

import 'index.dart';

class ErrorTest1Model extends MomentumModel<ErrorTest1Controller> {
  ErrorTest1Model(
    ErrorTest1Controller controller,
  ) : super(controller);

  @override
  void update() {
    ErrorTest1Model(
      controller,
    ).updateMomentum();
  }
}
