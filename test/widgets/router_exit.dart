import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';

import '../components/counter/index.dart';

const routerExitButtonKey = Key('routerExitButtonKey');

Momentum routerExitApp() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      Router([
        PageExitTest(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerExitApp', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerExitApp', context);
      var result = storage.getString(key);
      return result;
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Router.getActivePage(context),
    );
  }
}

class PageExitTest extends StatelessWidget {
  const PageExitTest({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: routerExitButtonKey,
          onPressed: () {
            Router.pop(context);
          },
          child: Text('Exit'),
        ),
      ),
    );
  }
}
