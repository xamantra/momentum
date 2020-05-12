import 'dart:async';

import 'package:momentum/momentum.dart';

import 'timer.model.dart';

class TimerController extends MomentumController<TimerModel> {
  @override
  TimerModel init() {
    return TimerModel(
      this,
      microseconds: 0,
      seconds: 0,
      minutes: 0,
      hours: 0,
    );
  }

  @override
  Future<void> bootstrap() async {
    Timer.periodic(Duration(hours: 1), (value) {
      model.update(hours: (model.hours + 1) % 60);
    });
    Timer.periodic(Duration(minutes: 1), (value) {
      model.update(minutes: (model.minutes + 1) % 60);
    });
    Timer.periodic(Duration(seconds: 1), (value) {
      model.update(seconds: (model.seconds + 1) % 60);
    });
    Timer.periodic(Duration(microseconds: 1), (value) {
      model.update(microseconds: (model.microseconds + 1) % 1000);
    });
  }

  String getLabel() {
    var result = 'Time elapsed since';
    if (isLazy) {
      result += ' this controller was loaded for the first time:';
    } else {
      result += ' the application started:';
    }
    return result;
  }
}
