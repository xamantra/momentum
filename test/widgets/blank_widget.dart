import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

Momentum blankWidget() {
  return Momentum(
    child: BlankApp(),
    controllers: null,
    services: null,
  );
}

class BlankApp extends StatelessWidget {
  const BlankApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blank App',
      home: Scaffold(
        body: Text('Blank App'),
      ),
    );
  }
}
