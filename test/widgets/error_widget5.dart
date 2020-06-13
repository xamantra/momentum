import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/dummy/index.dart';

Momentum errorWidget5() {
  return Momentum(
    child: ErrorApp5(),
    controllers: [CounterController()],
  );
}

class ErrorApp5 extends StatelessWidget {
  const ErrorApp5({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            dontRebuildIf: (controller, _) {
              controller<DummyController>();
              return false;
            },
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
