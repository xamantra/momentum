import 'package:momentum/momentum.dart';

import 'index.dart';

class InjectServiceModel extends MomentumModel<InjectServiceController> {
  InjectServiceModel(InjectServiceController controller) : super(controller);

  @override
  void update() {
    InjectServiceModel(
      controller,
    ).updateMomentum();
  }
}
