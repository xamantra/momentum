import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';

import '../components/dummy/index.dart';
import '../components/sync-test/index.dart';

Momentum syncApp({bool lazy = true}) {
  return Momentum(
    child: SyncApp(),
    controllers: [
      SyncTestController()..config(lazy: lazy),
      DummyController(),
    ],
  );
}

class SyncApp extends StatefulWidget {
  const SyncApp({
    Key key,
  }) : super(key: key);

  @override
  _AsyncAppState createState() => _AsyncAppState();
}

class _AsyncAppState extends MomentumState<SyncApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [SyncTestController],
            builder: (context, snapshot) {
              var syncTest = snapshot<SyncTestModel>();
              return Column(
                children: <Widget>[
                  Text('${syncTest.value}'),
                  Text('${syncTest.name}'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
