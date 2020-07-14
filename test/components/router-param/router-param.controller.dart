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
    var value = getParam<TestRouterParamsC>().value;
    return value;
  }

  @override
  void onRouteChanged(RouterParam param) {
    if (param is TestRouterParamsC) {
      print("onRouteParamReceived: ${param.value}");
    }
  }
}
