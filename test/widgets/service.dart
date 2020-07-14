import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

Momentum serviceWidget() {
  return Momentum(
    child: CounterApp(),
    controllers: [],
    services: [
      ServiceA(),
      ServiceB(),
    ],
  );
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service App',
      home: Scaffold(),
    );
  }
}

class ServiceA extends MomentumService {
  int increment(int value) => value + 1;

  double times2(double value) {
    var serviceB = getService<ServiceB>();
    return serviceB._times2(value);
  }
}

class ServiceB extends MomentumService {
  double _times2(double value) => value * 2;
}
