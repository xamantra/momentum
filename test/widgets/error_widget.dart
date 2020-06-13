import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

Momentum errorWidget() {
  return Momentum(
    child: ErrorApp(),
    controllers: [CounterController()],
  );
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            builder: null,
          ),
        ),
      ),
    );
  }
}
