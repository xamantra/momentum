import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/sync-test/index.dart';

const resetAllButtonKey = Key('resetAllButtonKey');

Momentum resetAllWidget() {
  return Momentum(
    child: ResetAllApp(),
    controllers: [
      CounterController(),
      SyncTestController()..config(lazy: false),
    ],
  );
}

class ResetAllApp extends StatelessWidget {
  const ResetAllApp({Key key}) : super(key: key);

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
                    key: resetAllButtonKey,
                    onPressed: () {
                      Momentum.resetAll(context);
                    },
                    child: Text('Reset All'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
