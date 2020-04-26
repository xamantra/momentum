import 'package:momentum/momentum.dart';

import 'timer.controller.dart';

class TimerModel extends MomentumModel<TimerController> {
  TimerModel(
    TimerController controller, {
    this.microseconds,
    this.seconds,
    this.minutes,
    this.hours,
  }) : super(controller);

  final int microseconds;
  final int seconds;
  final int minutes;
  final int hours;

  @override
  void update({
    int microseconds,
    int seconds,
    int minutes,
    int hours,
  }) {
    TimerModel(
      controller,
      microseconds: microseconds ?? this.microseconds,
      seconds: seconds ?? this.seconds,
      minutes: minutes ?? this.minutes,
      hours: hours ?? this.hours,
    ).updateMomentum();
  }
}
