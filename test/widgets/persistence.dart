import 'package:flutter/material.dart';

import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';

import '../components/dummy/dummy.controller.dart';
import '../components/persist-error1/index.dart';
import '../components/persist-error2/index.dart';
import '../components/persist-error3/index.dart';
import '../components/persist-error4/index.dart';
import '../components/persist-test/index.dart';

Momentum persistedApp({
  bool noPersistSave = false,
  bool noPersistGet = false,
  bool fakeFailSave = false,
  bool disabledPersistentState = false,
  String sessionId = '',
  bool testMode = false,
}) {
  return Momentum(
    testMode: testMode,
    testSessionName: sessionId,
    child: PersistedApp(),
    controllers: [
      DummyController(),
      PersistTestController(),
      PersistErrorController(),
      PersistError2Controller(),
      PersistError3Controller(),
      PersistError4Controller(),
    ],
    disabledPersistentState: disabledPersistentState ?? false,
    enableLogging: true,
    services: [
      InMemoryStorage(),
    ],
    persistSave: noPersistSave
        ? null
        : (context, key, value) async {
            if (fakeFailSave) return false;
            var storage = InMemoryStorage.of('persistedApp$sessionId', context);
            var result = storage.setString(key, value);
            return result;
          },
    persistGet: noPersistGet
        ? null
        : (context, key) async {
            var storage = InMemoryStorage.of('persistedApp', context);
            var result = storage.getString(key);
            return result;
          },
  );
}

class PersistedApp extends StatefulWidget {
  const PersistedApp({
    Key key,
  }) : super(key: key);

  @override
  _PersistedAppState createState() => _PersistedAppState();
}

class _PersistedAppState extends MomentumState<PersistedApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Async App',
      home: Scaffold(
        body: SizedBox(),
      ),
    );
  }
}
