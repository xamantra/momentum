import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/dummy/dummy.controller.dart';
import '../components/sync-test/index.dart';

Momentum errorWidget8() {
  return Momentum(
    child: ErrorApp8(),
    controllers: [
      DummyController(),
      CounterController(),
    ],
  );
}

class ErrorApp8 extends StatelessWidget {
  const ErrorApp8({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Momentum.controller<SyncTestController>(context);
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            builder: (context, snapshot) {
              var counter = snapshot<CounterModel>();
              return Text('${counter.value}');
            },
          ),
        ),
      ),
    );
  }
}
