import 'package:momentum/momentum.dart';

import 'index.dart';

class DummyModel extends MomentumModel<DummyController> {
  DummyModel(DummyController controller) : super(controller);

  @override
  void update() {
    DummyModel(
      controller,
    ).updateMomentum();
  }
}
