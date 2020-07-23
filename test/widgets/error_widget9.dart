import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/error-test-4/index.dart';

Momentum errorWidget9() {
  return Momentum(
    child: ErrorApp9(),
    controllers: [
      ErrorTest4Controller()..config(lazy: false),
    ],
  );
}

class ErrorApp9 extends StatelessWidget {
  const ErrorApp9({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ErrorApp9',
      home: Scaffold(),
    );
  }
}
