import 'package:momentum/momentum.dart';

import 'index.dart';

class StrategyController extends MomentumController<StrategyModel> {
  @override
  StrategyModel init() {
    return StrategyModel(
      this,
      loading: false,
    );
  }

  @override
  void bootstrap() {
    model.update(loading: true);
  }

  void stopLoading() {
    model.update(loading: false);
  }
}
