import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/error-test-1/index.dart';

Momentum error1({bool lazy = true}) {
  return Momentum(
    child: Error1(),
    controllers: [
      ErrorTest1Controller(),
    ],
  );
}

class Error1 extends StatefulWidget {
  const Error1({
    Key key,
  }) : super(key: key);

  @override
  _Error1State createState() => _Error1State();
}

class _Error1State extends MomentumState<Error1> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync App',
      home: Scaffold(
        body: SizedBox(),
      ),
    );
  }
}
