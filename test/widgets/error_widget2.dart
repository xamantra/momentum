import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../components/dummy/dummy.controller.dart';
import '../components/dummy/index.dart';

Momentum errorWidget2() {
  return Momentum(
    child: ErrorApp2(),
    controllers: [CounterController()],
  );
}

class ErrorApp2 extends StatelessWidget {
  const ErrorApp2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [DummyController],
            builder: (context, snapshot) {
              var dummyModel = snapshot<DummyModel>();
              return Text('${dummyModel.controllerName}');
            },
          ),
        ),
      ),
    );
  }
}
