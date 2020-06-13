import 'package:momentum/momentum.dart';

import 'index.dart';

class ErrorTest3Model extends MomentumModel<ErrorTest3Controller> {
  ErrorTest3Model(ErrorTest3Controller controller) : super(controller);

  @override
  void update() {
    ErrorTest3Model(
      controller,
    ).updateMomentum();
  }
}
