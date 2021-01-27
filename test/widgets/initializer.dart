import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

int initializedValue;
void initialize(int value) {
  initializedValue = value;
}

Momentum initializerTest(int value) {
  return Momentum(
    child: InitializerTest(),
    initializer: () async {
      initialize(value);
    },
    controllers: [],
  );
}

class InitializerTest extends StatelessWidget {
  const InitializerTest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Text('$initializedValue'),
    );
  }
}
