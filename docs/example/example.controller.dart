import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleController extends MomentumController<ExampleModel> {
  @override
  ExampleModel init() {
    return ExampleModel(
      this,
      // TODO: specify initial values here...
    );
  }
}
