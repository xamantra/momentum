import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/dummy/dummy.controller.dart';

Momentum errorWidget7() {
  return Momentum(
    child: ErrorApp7(),
    controllers: [
      DummyController(),
      CounterController(),
      DummyController(),
    ],
  );
}

class ErrorApp7 extends StatelessWidget {
  const ErrorApp7({Key key}) : super(key: key);

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
