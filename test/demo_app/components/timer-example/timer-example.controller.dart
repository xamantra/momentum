import 'dart:async';

import 'package:momentum/momentum.dart';

import 'index.dart';

/// This controller doesn't just manage the state but also
/// the proper handling of the `Timer` object.
class TimerExampleController extends MomentumController<TimerExampleModel> {
  @override
  TimerExampleModel init() {
    return TimerExampleModel(
      this,
      seconds: 0,
      started: false,
    );
  }

  // Keep a reference to the timer object.
  late Timer timer;

  void startTimer() {
    model.update(started: true);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      var current = model.seconds!;
      model.update(seconds: current + 1);
    });
  }

  void stopTimer() {
    model.update(started: false, seconds: 0);
    // use the saved timer reference to stop it.
    timer.cancel();
  }
}
