import 'package:momentum/momentum.dart';

import '../../widgets/router_params.dart';
import 'index.dart';

// ignore: lines_longer_than_80_chars
class RouterParamController extends MomentumController<RouterParamModel> with RouterMixin {
  @override
  RouterParamModel init() {
    return RouterParamModel(
      this,
    );
  }

  String getParamValue() {
    var value = getParams<TestRouterParamsC>().value;
    return value;
  }
}
