import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/async-test/index.dart';

Momentum timeTravelApp({bool lazy = true, bool enableLogging = true}) {
  return Momentum(
    child: TimeTravelApp(),
    controllers: [
      AsyncTestController()..config(lazy: lazy, maxTimeTravelSteps: 5),
    ],
    enableLogging: enableLogging,
  );
}

class TimeTravelApp extends StatefulWidget {
  const TimeTravelApp({Key key}) : super(key: key);
  @override
  _TimeTravelAppState createState() => _TimeTravelAppState();
}

class _TimeTravelAppState extends MomentumState<TimeTravelApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Async App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [AsyncTestController],
            builder: (context, snapshot) {
              var asyncTest = snapshot<AsyncTestModel>();
              return Column(
                children: <Widget>[
                  Text('${asyncTest.value}'),
                  Text('${asyncTest.name}'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
