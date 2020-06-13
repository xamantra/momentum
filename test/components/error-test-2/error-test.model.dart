import 'package:momentum/momentum.dart';

import 'index.dart';

class ErrorTest2Model extends MomentumModel<ErrorTest2Controller> {
  ErrorTest2Model(
    ErrorTest2Controller controller,
  ) : super(controller);

  @override
  void update() {
    ErrorTest2Model(
      controller,
    ).updateMomentum();
  }
}
