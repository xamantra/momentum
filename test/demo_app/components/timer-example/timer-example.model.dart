import 'package:momentum/momentum.dart';

import 'index.dart';

class TimerExampleModel extends MomentumModel<TimerExampleController> {
  TimerExampleModel(
    TimerExampleController controller, {
    this.seconds,
    this.started,
  }) : super(controller);

  final int? seconds;
  final bool? started;

  @override
  void update({
    int? seconds,
    bool? started,
  }) {
    TimerExampleModel(
      controller,
      seconds: seconds ?? this.seconds,
      started: started ?? this.started,
    ).updateMomentum();
  }
}
