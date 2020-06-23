import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

const keyCounterIncrementButtonCallback = Key(
  'keyCounterIncrementButtonCallback',
);
const keyRestartButtonCallback = Key(
  'keyRestartButtonCallback',
);

void mockMain() {
// runApp(counterRestartCallback());
}

Momentum counterRestartCallback() {
  return Momentum(
    key: UniqueKey(),
    restartCallback: mockMain,
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
                  FlatButton(
                    key: keyRestartButtonCallback,
                    child: Text('Restart'),
                    onPressed: () {
                      Momentum.restart(context, counterRestartCallback());
                    },
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: keyCounterIncrementButtonCallback,
          onPressed: () {
            Momentum.controller<CounterController>(context).increment();
          },
        ),
      ),
    );
  }
}
