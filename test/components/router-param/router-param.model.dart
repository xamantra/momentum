import 'package:momentum/momentum.dart';

import 'index.dart';

class RouterParamModel extends MomentumModel<RouterParamController> {
  RouterParamModel(RouterParamController controller) : super(controller);

  @override
  void update() {
    RouterParamModel(
      controller,
    ).updateMomentum();
  }
}
