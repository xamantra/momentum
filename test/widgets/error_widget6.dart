import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

Momentum errorWidget6() {
  return Momentum(
    child: ErrorApp6(),
    controllers: [
      CounterController(),
      null,
    ],
  );
}

class ErrorApp6 extends StatelessWidget {
  const ErrorApp6({Key key}) : super(key: key);

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
              return Text('${counter.value}');
            },
          ),
        ),
      ),
    );
  }
}
