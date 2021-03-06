import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart' as momentum;
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';

import '../components/counter/index.dart';

const errorTestGotoPageBKey = Key('errorTestGotoPageBKey');

Momentum routerErrorTest() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      momentum.MomentumRouter([
        PageErrorTestA(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerErrorTest', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerErrorTest', context);
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
      home: momentum.MomentumRouter.getActivePage(context),
    );
  }
}

class PageErrorTestA extends StatelessWidget {
  const PageErrorTestA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: errorTestGotoPageBKey,
          onPressed: () {
            momentum.MomentumRouter.goto(context, PageErrorTestB);
          },
          child: Text('Goto PageB'),
        ),
      ),
    );
  }
}

class PageErrorTestB extends StatelessWidget {
  const PageErrorTestB({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('PageB'),
      ),
    );
  }
}
