import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/async-test/index.dart';

Momentum resetApp({bool lazy = true, bool enableLogging = true}) {
  return Momentum(
    child: TestApp(),
    controllers: [
      AsyncTestController()..config(lazy: lazy, maxTimeTravelSteps: 5),
    ],
    enableLogging: enableLogging,
  );
}

class TestApp extends StatefulWidget {
  const TestApp({Key key}) : super(key: key);
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends MomentumState<TestApp> {
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
