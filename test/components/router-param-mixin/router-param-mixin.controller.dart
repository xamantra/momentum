import 'package:momentum/momentum.dart';

import 'index.dart';

// ignore: lines_longer_than_80_chars
class RouterParamMixinController extends MomentumController<RouterParamMixinModel> with RouterMixin {
  @override
  RouterParamMixinModel init() {
    return RouterParamMixinModel(
      this,
    );
  }
}
