import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

const keyCounterValue = Key('keyCounterValue');
const keyIncrementButton = Key('keyIncrementButton');

Momentum counter() {
  return Momentum(
    child: CounterApp(),
    controllers: [CounterController()],
  );
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            builder: (context, snapshot) {
              var counter = snapshot<CounterModel>();
              return Text('${counter.value}', key: keyCounterValue);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: keyIncrementButton,
          onPressed: () {
            Momentum.controller<CounterController>(context).increment();
          },
        ),
      ),
    );
  }
}
