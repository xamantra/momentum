import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/dummy/index.dart';

Momentum errorWidget4() {
  return Momentum(
    child: ErrorApp4(),
    controllers: [CounterController()],
  );
}

class ErrorApp4 extends StatelessWidget {
  const ErrorApp4({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            builder: (context, snapshot) {
              var dummy = snapshot<DummyModel>();
              return Text('${dummy.controllerName}');
            },
          ),
        ),
      ),
    );
  }
}
