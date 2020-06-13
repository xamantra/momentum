import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

Momentum errorWidget3() {
  return Momentum(
    child: ErrorApp3(),
    controllers: [CounterController()],
  );
}

class ErrorApp3 extends StatelessWidget {
  const ErrorApp3({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: null,
            builder: (context, snapshot) {
              var counter = snapshot<CounterModel>();
              return Text('${counter.controllerName}');
            },
          ),
        ),
      ),
    );
  }
}
