import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/async-test/index.dart';
import '../components/dummy/index.dart';
import '../components/persist-test/index.dart';
import '../utility.dart';

Momentum asyncApp({
  bool lazy = true,
  void Function(
    dynamic actual,
    dynamic matcher, {
    String reason,
    dynamic skip,
  })
      expect,
}) {
  return Momentum(
    child: AsyncApp(expect: expect),
    controllers: [
      AsyncTestController()..config(lazy: lazy, maxTimeTravelSteps: 5),
      PersistTestController()..config(lazy: lazy),
      DummyController(),
    ],
    services: [
      InMemoryStorage<String>(),
    ],
  );
}

class AsyncApp extends StatefulWidget {
  const AsyncApp({
    Key key,
    this.expect,
  }) : super(key: key);

  final void Function(
    dynamic actual,
    dynamic matcher, {
    String reason,
    dynamic skip,
  }) expect;

  @override
  _AsyncAppState createState() => _AsyncAppState();
}

class _AsyncAppState extends MomentumState<AsyncApp> {
  AsyncTestController asyncTestController;

  @override
  void initMomentumState() {
    if (widget.expect != null) {
      asyncTestController ??= Momentum.controller<AsyncTestController>(context);
      asyncTestController.listen<String>(
        state: this,
        invoke: (event) {
          widget.expect(event, 'test');
        },
      );
      asyncTestController.listen<AsyncEvent>(
        state: this,
        invoke: (event) {
          widget.expect(event.value, 117);
          widget.expect(event.message, 'test');
        },
      );
      asyncTestController.addListener(
        state: this,
        invoke: (model, isTimeTravel) {
          if (isTimeTravel) {
            widget.expect(model.value, 100);
            widget.expect(model.name, 'momentum');
          }
        },
      );
    }
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
