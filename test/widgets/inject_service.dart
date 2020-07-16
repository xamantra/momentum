import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';
import 'package:momentum/src/momentum_base.dart';

import '../components/inject-service/index.dart';
import '../utilities/dummy.dart';

const errorKey1 = Key('errorKey1');
const errorKey2 = Key('errorKey2');
const errorKey3 = Key('errorKey3');
const errorKey4 = Key('errorKey4');

class CalculatorService extends MomentumService {
  final bool enableLogs;

  CalculatorService({this.enableLogs = false});

  double add(double a, double b) {
    if (enableLogs) {
      print('Adding "$a" and "$b" ...');
      var result = a + b;
      print('Result: $result');
      return result;
    } else {
      return a + b;
    }
  }
}

enum CalcAlias {
  enableLogs,
  disableLogs,
}

Momentum injectService({bool duplicate = false}) {
  return Momentum(
    child: CounterApp(),
    controllers: [
      InjectServiceController(),
    ],
    services: duplicate
        ? [
            InjectService(CalcAlias.disableLogs, CalculatorService()),
            InjectService(CalcAlias.disableLogs, DummyService()),
          ]
        : [
            InjectService(CalcAlias.disableLogs, CalculatorService()),
            InjectService(
              CalcAlias.enableLogs,
              CalculatorService(
                enableLogs: true,
              ),
            ),
            DummyService(),
          ],
  );
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inject Service Widget',
      home: Scaffold(
        body: Column(
          children: <Widget>[
            FlatButton(
              key: errorKey1,
              onPressed: () {
                Momentum.service<InMemoryStorage>(context);
              },
              child: Text('Error Test 1'),
            ),
            FlatButton(
              key: errorKey2,
              onPressed: () {
                Momentum.service<InMemoryStorage>(
                  context,
                  alias: CalcAlias.enableLogs,
                );
              },
              child: Text('Error Test 2'),
            ),
            FlatButton(
              key: errorKey3,
              onPressed: () {
                Momentum.service<InjectService>(context);
              },
              child: Text('Error Test 3'),
            ),
            FlatButton(
              key: errorKey4,
              onPressed: () {
                Momentum.service<InjectService<dynamic>>(context);
              },
              child: Text('Error Test 4'),
            ),
          ],
        ),
      ),
    );
  }
}
