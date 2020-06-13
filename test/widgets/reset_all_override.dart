import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/sync-test/index.dart';

const resetAllOverrideButtonKey = Key('resetAllButtonKey');

Momentum resetAllOverrideWidget() {
  return Momentum(
    child: ResetAllOverrideApp(),
    controllers: [
      CounterController(),
      SyncTestController()..config(lazy: false),
    ],
    onResetAll: (context, resetAll) {
      var syncController = Momentum.controller<SyncTestController>(context);
      syncController.reset();
    },
  );
}

class ResetAllOverrideApp extends StatelessWidget {
  const ResetAllOverrideApp({Key key}) : super(key: key);

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
                    key: resetAllOverrideButtonKey,
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
