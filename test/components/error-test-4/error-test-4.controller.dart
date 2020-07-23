import 'package:momentum/momentum.dart';

import 'index.dart';

class ErrorTest4Controller extends MomentumController<ErrorTest4Model> {
  @override
  ErrorTest4Model init() {
    return ErrorTest4Model(
      this,
    );
  }

  @override
  void bootstrap() {
    var array = [23, 323];
    print(array[4]);
    return;
  }
}
