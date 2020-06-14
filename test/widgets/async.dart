import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/async-test/index.dart';
import '../components/dummy/index.dart';

Momentum asyncApp({bool lazy = true, bool enableLogging = true}) {
  return Momentum(
    child: AsyncApp(),
    controllers: [
      AsyncTestController()..config(lazy: lazy, maxTimeTravelSteps: 5),
      DummyController(),
    ],
    enableLogging: enableLogging,
  );
}

class AsyncApp extends StatefulWidget {
  const AsyncApp({Key key}) : super(key: key);
  @override
  _AsyncAppState createState() => _AsyncAppState();
}

class _AsyncAppState extends MomentumState<AsyncApp> {
  AsyncTestController asyncTestController;

  @override
  void initMomentumState() {
    asyncTestController ??= Momentum.controller<AsyncTestController>(context);
    asyncTestController.listen<String>(
      state: this,
      invoke: print,
    );
    asyncTestController.listen<AsyncEvent>(
      state: this,
      invoke: (event) {
        print([event.value, event.message]);
      },
    );
    asyncTestController.addListener(
      state: this,
      invoke: (model, isTimeTravel) {
        if (isTimeTravel) {
          print([model.value, model.name]);
        }
      },
    );
  }

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

@immutable
class AsyncEvent {
  final int value;
  final String message;

  AsyncEvent(this.value, this.message);
}
