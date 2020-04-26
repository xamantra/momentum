import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import 'src/momentum/counter-advance/counter-advance.controller.dart';
import 'src/momentum/counter-extreme/counter-extreme.controller.dart';
import 'src/momentum/counter-insane/counter-insane.controller.dart';
import 'src/momentum/counter/counter.controller.dart';
import 'src/momentum/timer/timer.controller.dart';
import 'src/momentum/undo-redo/undo-redo.controller.dart';
import 'src/widgets/home/home.dart';

void main() {
  runApp(
    Momentum(
      controllers: [
        CounterController(),
        CounterAdvanceController(),
        CounterExtremeController(),
        CounterInsaneController()..config(maxTimeTravelSteps: 200),
        UndoRedoController()..config(maxTimeTravelSteps: 200),
        TimerController()..config(lazy: true) // try changing the value of `lazy` to false and see the difference.
      ],
      enableLogging: false,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum State Management Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
