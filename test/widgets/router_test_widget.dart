import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../utilities/in_memory_storage.dart';

const gotoPageBKey = Key('Goto PageB');
const gotoPageCKey = Key('Goto PageC');
const fromPageCPop = Key('From PageC Pop');
const clearHistoryButton = Key('clearHistoryButton');
const resetHistoryButton = Key('resetHistoryButton');

Momentum routerTestWidget() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      Router([
        PageA(),
        PageB(),
        PageC(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerTestWidget', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerTestWidget', context);
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

class PageA extends StatelessWidget {
  const PageA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              key: gotoPageBKey,
              onPressed: () {
                Router.goto(context, PageB);
              },
              child: Text('Goto PageB'),
            ),
            FlatButton(
              key: resetHistoryButton,
              onPressed: () {
                Router.resetWithContext<PageB>(context);
              },
              child: Text('Reset Router'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: gotoPageCKey,
          onPressed: () {
            Router.goto(context, PageC);
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  const PageC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              key: fromPageCPop,
              onPressed: () {
                Router.pop(context);
              },
              child: Text('Pop From PageC'),
            ),
            FlatButton(
              key: clearHistoryButton,
              onPressed: () {
                Router.clearHistoryWithContext(context);
              },
              child: Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}
