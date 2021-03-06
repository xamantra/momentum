import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

const keyCounterIncrementButton = Key('keyCounterIncrementButton');
const keyRestartButton = Key('keyRestartButton');

Momentum counterRestart() {
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
              return Column(
                children: <Widget>[
                  Text('${counter.value}'),
                  TextButton(
                    key: keyRestartButton,
                    child: Text('Restart'),
                    onPressed: () {
                      Momentum.restart(context, counterRestart());
                    },
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: keyCounterIncrementButton,
          onPressed: () {
            Momentum.controller<CounterController>(context).increment();
          },
        ),
      ),
    );
  }
}
