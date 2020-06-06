import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleModel extends MomentumModel<ExampleController> {
  ExampleModel(ExampleController controller) : super(controller);

  // TODO: add your final properties here...

  @override
  void update() {
    ExampleModel(
      controller,
    ).updateMomentum();
  }
}
