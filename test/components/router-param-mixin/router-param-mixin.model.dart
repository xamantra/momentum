import 'package:momentum/momentum.dart';

import 'index.dart';

class RouterParamMixinModel extends MomentumModel<RouterParamMixinController> {
// ignore: lines_longer_than_80_chars
  RouterParamMixinModel(RouterParamMixinController controller) : super(controller);

  @override
  void update() {
    RouterParamMixinModel(
      controller,
    ).updateMomentum();
  }
}
