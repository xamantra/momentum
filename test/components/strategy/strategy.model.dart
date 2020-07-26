import 'package:momentum/momentum.dart';

import 'index.dart';

class StrategyModel extends MomentumModel<StrategyController> {
  StrategyModel(
    StrategyController controller, {
    this.loading,
  }) : super(controller);

  final bool loading;

  @override
  void update({
    bool loading,
  }) {
    StrategyModel(
      controller,
      loading: loading ?? this.loading,
    ).updateMomentum();
  }
}
