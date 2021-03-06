import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/momentum.dart' as momentum;
import 'package:momentum/src/in_memory_storage.dart';

import '../components/counter/index.dart';

const gotoRouterPageB = Key('gotoRouterPageB');
const gotoRouterPopKey = Key('gotoRouterPopKey');

Momentum routerPageTest() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      momentum.MomentumRouter([
        RouterPageA(),
        RouterPageB(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerPageTest', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerPageTest', context);
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

class RouterPageA extends StatelessWidget {
  const RouterPageA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RouterPage(
      child: Scaffold(
        appBar: AppBar(leading: BackButton()),
        body: Center(
          child: Column(
            children: <Widget>[
              TextButton(
                key: gotoRouterPageB,
                onPressed: () {
                  momentum.MomentumRouter.goto(context, RouterPageB);
                },
                child: Text('Goto PageB'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouterPageB extends StatelessWidget {
  const RouterPageB({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RouterPage(
      onWillPop: () async {
        momentum.MomentumRouter.pop(context);
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              TextButton(
                key: gotoRouterPopKey,
                onPressed: () {
                  momentum.MomentumRouter.pop(context);
                },
                child: Text('Pop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
