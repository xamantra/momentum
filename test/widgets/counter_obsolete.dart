import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

const keyCounterTestValue = Key('keyCounterValue');
const keyCounterObsoleteIncrement = Key('keyIncrementButton');

Momentum counterObsolete() {
  return Momentum(
    child: CounterObsoleteApp(),
    controllers: [CounterController()],
  );
}

class CounterObsoleteApp extends StatelessWidget {
  const CounterObsoleteApp({Key key}) : super(key: key);

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
              return Text('${counter.value}', key: keyCounterTestValue);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: keyCounterObsoleteIncrement,
          onPressed: () {
            Momentum.of<CounterController>(context).increment();
          },
        ),
      ),
    );
  }
}
